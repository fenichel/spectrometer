import processing.serial.*;

Serial myPort; 
String val;    
int[] data; 
double[] summed;
float[] wavelengths;
float[] output; 
float[] irrad; 
int draw_sum=0;

float A0 = 3.078252499E2;
float B1 = 2.695942800E0;
float B2 = -1.114765702E-3;
float B3 = -7.640370670E-6;
float B4 = 8.858842365E-09;
float B5 = 5.624572433E-12;

float lin_a = 0.12032;
float lin_b = 3.89444;

int dark_value = 110;
float max_value = 850;

int bottom_spacing = 40;
int window_height = 1024;
int min_wavelength = 317;
int max_wavelength = 891;
int width_multiplier = 8;

/** Return the maximum value in an array of doubles. **/
double find_max(double[] input) {
  double max = 0;
  for (int i = 0; i < input.length; i++) {
    if (input[i] > max) {
      max = input[i];
    }
  }
  return max;
}

void plotdata() {
  background(300); 
  for (int i = 0; i < output.length; i++) {
    float x = width_multiplier * (wavelengths[i] - 315);
    float y1 = window_height - bottom_spacing;
    float y2 = window_height - irrad[i] * window_height / 0.6;
    
    line(x, y1, x, y2);
    strokeWeight(width_multiplier + 3);
    
    int[] rgbWavelengths = waveLengthToRGB(wavelengths[i]);
    stroke(rgbWavelengths[0], rgbWavelengths[1], rgbWavelengths[2]);

    if (i % 13 == 0) {
      //println(int(wavelengths[i]));
      textSize(20);
      text(int(wavelengths[i]), width_multiplier*(wavelengths[i]- 315), window_height-10);
      fill(200);
    }
  }
}

float scale_wavelength(int pix) {
  return A0 +
    B1 * pix +
    B2 * pix * pix +
    B3 * pix * pix * pix +
    B4 * pix * pix * pix * pix +
    B5 * pix * pix * pix * pix * pix;
}

// Compensates for differences in the sensor's response, which
// is nonlinear with the number of photons received.
float scale_linearity(int count) {
  return (count / (lin_a * log((count + 1) * lin_b)));
}

void settings() {
  size(width_multiplier * 566, window_height);
}

void setup() {

  println(Serial.list());
  String portName = Serial.list()[0]; //This is the index into the serial list, if you only have one serial device the index is 0
  myPort = new Serial(this, portName, 115200);

  summed = new double[288];
  output = new float[288];
  irrad = new float[288];
  wavelengths = new float[288];

  colorMode(RGB, 400);

  // Initialize the arrays.
  for (int i = 0; i < 288; i++) {
    summed[i] = 0;
    output[i] = 0;
    // The wavelength buckets are not evenly placed.
    // scale_wavelength maps from bucket number to wavelength.
    wavelengths[i] = scale_wavelength(i);
  }
}

void draw() {
  if ( myPort.available() > 0) {  
    val = myPort.readStringUntil('\n');         // read it and store it in val
    if (val != null) {
      // Entries in data are between 0 and 1024.
      data = int(split(val, ','));
      for (int i = 0; i < data.length; i++) {
        if (i < summed.length) {
          float scaled_value = scale_linearity(data[i] - dark_value);
          println(i, data[i], scaled_value);
          output[i] = scaled_value;
          irrad[i] = scaled_value / irradiance_cal[i];
          summed[i] += data[i];
        }
      }
      plotdata();
    }
  }
}

static private final double Gamma = 1;
static private final double IntensityMax = 400;

/**
 * Taken from Earl F. Glynn's web page:
 * <a href="http://www.efg2.com/Lab/ScienceAndEngineering/Spectra.htm">Spectra Lab Report</a>
 */
int[] waveLengthToRGB(double Wavelength) {
  double factor;
  double Red, Green, Blue;

  if ((Wavelength >= 380) && (Wavelength < 440)) {
    Red = -(Wavelength - 440) / (440 - 380);
    Green = 0.0;
    Blue = 1.0;
  } else if ((Wavelength >= 440) && (Wavelength < 490)) {
    Red = 0.0;
    Green = (Wavelength - 440) / (490 - 440);
    Blue = 1.0;
  } else if ((Wavelength >= 490) && (Wavelength < 510)) {
    Red = 0.0;
    Green = 1.0;
    Blue = -(Wavelength - 510) / (510 - 490);
  } else if ((Wavelength >= 510) && (Wavelength < 580)) {
    Red = (Wavelength - 510) / (580 - 510);
    Green = 1.0;
    Blue = 0.0;
  } else if ((Wavelength >= 580) && (Wavelength < 645)) {
    Red = 1.0;
    Green = -(Wavelength - 645) / (645 - 580);
    Blue = 0.0;
  } else if ((Wavelength >= 645) && (Wavelength < 781)) {
    Red = 1.0;
    Green = 0.0;
    Blue = 0.0;
  } else {
    Red = 0.0;
    Green = 0.0;
    Blue = 0.0;
  }

  // Let the intensity fall off near the vision limits

  if ((Wavelength >= 380) && (Wavelength < 420)) {
    factor = 0.3 + 0.7 * (Wavelength - 380) / (420 - 380);
  } else if ((Wavelength >= 420) && (Wavelength < 701)) {
    factor = 1.0;
  } else if ((Wavelength >= 701) && (Wavelength < 781)) {
    factor = 0.3 + 0.7 * (780 - Wavelength) / (780 - 700);
  } else {
    factor = 0.0;
  }


  int[] rgb = new int[3];

  // Don't want 0^x = 1 for x <> 0
  rgb[0] = Red == 0.0 ? 0 : (int)Math.round(IntensityMax * Math.pow(Red * factor, Gamma));
  rgb[1] = Green == 0.0 ? 0 : (int)Math.round(IntensityMax * Math.pow(Green * factor, Gamma));
  rgb[2] = Blue == 0.0 ? 0 : (int)Math.round(IntensityMax * Math.pow(Blue * factor, Gamma));

  return rgb;
}


// The sensor responds differently to different wavelengths of light
// because it has a diffraction grating and a mirror.
// This array is specific to this sensor and contains one entry per
// wavelength bucket (288 total).
float[] irradiance_cal = {
  1244.452738, 
  1325.101981, 
  1366.333849, 
  1386.963143, 
  1396.964204, 
  1405.829191, 
  1402.692229, 
  1413.239925, 
  1439.81767, 
  1458.830745, 
  1477.121658, 
  1482.141716, 
  1473.699976, 
  1455.932302, 
  1425.558361, 
  1393.304134, 
  1361.468341, 
  1340.229275, 
  1334.214201, 
  1340.112899, 
  1369.159646, 
  1408.551555, 
  1461.086474, 
  1515.423943, 
  1562.186711, 
  1603.765326, 
  1627.017565, 
  1633.604297, 
  1625.530283, 
  1604.272691, 
  1580.27003, 
  1553.615104, 
  1533.562355, 
  1522.762318, 
  1528.963183, 
  1551.574363, 
  1587.958092, 
  1643.931024, 
  1713.049621, 
  1791.451132, 
  1876.056087, 
  1958.387825, 
  2036.951654, 
  2110.322046, 
  2169.067876, 
  2215.232434, 
  2244.36054, 
  2258.112336, 
  2256.452481, 
  2241.784749, 
  2214.89716, 
  2182.076433, 
  2145.818971, 
  2104.979222, 
  2067.306755, 
  2036.663031, 
  2011.405525, 
  1997.162757, 
  1991.720735, 
  1997.446406, 
  2007.706301, 
  2026.901394, 
  2051.002447, 
  2085.392213, 
  2130.102896, 
  2178.246133, 
  2225.895323, 
  2281.014153, 
  2338.794111, 
  2393.716348, 
  2440.403622, 
  2486.697973, 
  2519.723278, 
  2542.431106, 
  2546.997039, 
  2535.54835, 
  2511.23446, 
  2474.140297, 
  2419.692364, 
  2358.113654, 
  2296.648381, 
  2244.482222, 
  2197.329247, 
  2165.14273, 
  2145.244818, 
  2134.104995, 
  2131.489929, 
  2132.050575, 
  2136.572215, 
  2142.302282, 
  2144.851275, 
  2148.539535, 
  2149.720572, 
  2148.927201, 
  2145.208954, 
  2138.621896, 
  2129.718, 
  2116.862616, 
  2102.558965, 
  2085.340595, 
  2069.004814, 
  2053.815073, 
  2037.996124, 
  2021.483645, 
  2004.955566, 
  1988.075779, 
  1973.021658, 
  1959.136869, 
  1943.679459, 
  1932.741216, 
  1924.325461, 
  1915.43737, 
  1908.637298, 
  1902.898909, 
  1899.581921, 
  1895.551756, 
  1890.096661, 
  1885.418059, 
  1880.978806, 
  1876.691318, 
  1870.006608, 
  1864.606256, 
  1859.305924, 
  1854.858374, 
  1851.576188, 
  1849.665487, 
  1849.368913, 
  1850.870328, 
  1852.081974, 
  1852.097222, 
  1852.75915, 
  1850.798582, 
  1847.400284, 
  1841.918921, 
  1834.94098, 
  1826.644516, 
  1816.175826, 
  1805.155194, 
  1792.46838, 
  1777.151212, 
  1760.278804, 
  1742.077428, 
  1727.19423, 
  1711.524008, 
  1698.703699, 
  1687.290154, 
  1678.302259, 
  1668.565163, 
  1658.38532, 
  1645.116268, 
  1632.10635, 
  1617.448412, 
  1599.27814, 
  1582.013444, 
  1567.043418, 
  1554.891063, 
  1544.513561, 
  1531.579486, 
  1519.400085, 
  1504.05586, 
  1486.042671, 
  1464.656466, 
  1442.445675, 
  1421.262477, 
  1400.65209, 
  1383.161107, 
  1366.875567, 
  1354.983659, 
  1347.157339, 
  1340.451078, 
  1333.543514, 
  1325.097437, 
  1316.23049, 
  1303.980911, 
  1291.43365, 
  1274.76777, 
  1259.378578, 
  1246.254355, 
  1232.859889, 
  1223.961552, 
  1218.857553, 
  1214.914218, 
  1210.825516, 
  1204.538277, 
  1194.525226, 
  1178.104629, 
  1162.240303, 
  1145.132722, 
  1126.746002, 
  1112.987718, 
  1101.409789, 
  1091.592227, 
  1085.285682, 
  1079.124057, 
  1071.164472, 
  1063.681358, 
  1055.0913, 
  1044.735722, 
  1037.392688, 
  1034.360525, 
  1033.615276, 
  1036.739662, 
  1042.870835, 
  1039.233292, 
  1030.334086, 
  1015.48455, 
  998.6446799, 
  979.5751571, 
  960.9331512, 
  944.9688829, 
  936.4839509, 
  933.4712924, 
  931.6589347, 
  931.1983821, 
  934.540639, 
  933.2534288, 
  926.9079597, 
  918.7097657, 
  911.4840572, 
  902.4767981, 
  891.4744799, 
  877.1506991, 
  861.2797926, 
  846.2949113, 
  831.1168432, 
  820.0903495, 
  811.7181465, 
  806.7680678, 
  802.2166788, 
  798.6331634, 
  795.7592146, 
  790.2480671, 
  783.5786451, 
  776.609, 
  768.482, 
  760.355, 
  752.228, 
  744.101, 
  735.974, 
  727.847, 
  719.72, 
  711.593, 
  703.466, 
  695.339, 
  687.212, 
  679.085, 
  670.958, 
  662.831, 
  654.704, 
  646.577, 
  638.45, 
  630.323, 
  622.196, 
  614.069, 
  605.942, 
  597.815, 
  589.688, 
  581.561, 
  573.434, 
  565.307, 
  557.18, 
  549.053, 
  540.926, 
  532.799, 
  524.672, 
  516.545, 
  508.418, 
  500.291, 
  492.164, 
  484.037, 
  475.91, 
  467.783, 
  459.656, 
  451.529, 
  443.402, 
  435.275, 
  427.148, 
  419.021, 
  410.894, 
  402.767, 
  394.64, 
  386.513, 
  378.386, 
  370.259, 
  362.132, 
  354.005, 
  345.878, 
  337.751
};
