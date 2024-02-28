SurfaceColor g_next_surface_color = null;
String g_current_file = "rect_test.cli";
color g_background = color(0, 0, 0);
ArrayList<Surface> g_surfaces = null;
ArrayList<Light> g_lights = null;
float g_fov = 0;
ArrayList<Point> g_polygon_vertices = null;

void keyPressed() {
  switch (key) {
  case '1':
    g_current_file = new String("i1.cli");
    interpreter();
    break;
  case '2':
    g_current_file = new String("i10.cli");
    interpreter();
    break;
  case '3':
    g_current_file = new String("i2.cli");
    interpreter();
    break;
  case '4':
    g_current_file = new String("i3.cli");
    interpreter();
    break;
  case '5':
    g_current_file = new String("i4.cli");
    interpreter();
    break;
  case '6':
    g_current_file = new String("i5.cli");
    interpreter();
    break;
  case '7':
    g_current_file = new String("i6.cli");
    interpreter();
    break;
  case '8':
    g_current_file = new String("i7.cli");
    interpreter();
    break;
  case '9':
    g_current_file = new String("i8.cli");
    interpreter();
    break;
  case '0':
    g_current_file = new String("i9.cli");
    interpreter();
    break;
  }
}

void interpreter() {
  String str[] = loadStrings(g_current_file);
  if (str == null)
    println("Error! Failed to read the file.");

  g_surfaces = new ArrayList<Surface>();
  g_lights = new ArrayList<Light>();
  g_background = color(0, 0, 0);

  boolean dontshoot = false;

  for (int i = 0; i < str.length; i++) {
    println("LINE: " + str[i]);
    String[] token = splitTokens(str[i], " ");
    if (token.length == 0)
      continue;

    if (token[0].equals("fov")) {
      g_fov = float(token[1]);
      println("fov: " + g_fov);
      continue;
    } else if (token[0].equals("background")) {
      // background r g b
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      g_background = color(r, g, b);
      println("background: " + g_background);
      continue;
    } else if (token[0].equals("light")) {
      // light x y z r g b
      g_lights.add(new Light(float(token[1]), float(token[2]), float(token[3]),
                             float(token[4]), float(token[5]),
                             float(token[6])));
      println("light: " + g_lights);
      continue;
    } else if (token[0].equals("surface")) {
      // surface Cdr Cdg Cdb Car Cag Cab Csr Csg Csb P Krefl
      float Cdr = float(token[1]);
      float Cdg = float(token[2]);
      float Cdb = float(token[3]); // difuse
      float Car = float(token[4]);
      float Cag = float(token[5]);
      float Cab = float(token[6]); // ambient
      float Csr = float(token[7]);
      float Csg = float(token[8]);
      float Csb = float(token[9]);          // specular
      float phong = float(token[10]);       // phong
      float reflectance = float(token[11]); // reflectance
      g_next_surface_color = new SurfaceColor(Cdr, Cdg, Cdb, Car, Cag, Cab, Csr,
                                              Csg, Csb, phong, reflectance);
      continue;
    } else if (token[0].equals("sphere")) {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      float r = float(token[4]);
      g_surfaces.add(new Ball(new Point(x, y, z), r));
      println("sphere: " + g_surfaces);
      continue;
    } else if (token[0].equals("begin")) {
      g_polygon_vertices = new ArrayList<Point>();
      continue;
    } else if (token[0].equals("vertex")) {
      // vertex x y z
      g_polygon_vertices.add(new Point(float(token[1]) + 0.001,
                                       float(token[2]) + 0.001,
                                       float(token[3]) + 0.001));
      continue;
    } else if (token[0].equals("end")) {
      if (g_polygon_vertices.size() < 3)
        ASSERT("Not enough vertices to make a triangle");
      g_surfaces.add(new Triangle(g_polygon_vertices.get(0),
                                  g_polygon_vertices.get(1),
                                  g_polygon_vertices.get(2)));
      continue;
    } else if (token[0].equals("color")) {
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      fill(r, g, b);
      continue;
    } else if (token[0].equals("rect")) {
      float x0 = float(token[1]);
      float y0 = float(token[2]);
      float x1 = float(token[3]);
      float y1 = float(token[4]);
      rect(x0, height - y1, x1 - x0, y1 - y0);
      dontshoot = true;
      continue;
    } else if (token[0].equals("write")) {
      if (!dontshoot)
        shootrays();
      dontshoot = false;
      save(token[1]);
      continue;
    }

    println("Undefined symbol: " + token[0]);
  }
}

void setup() {
  size(300, 300);
  noStroke();
  colorMode(RGB, 1.0);
  background(0, 0, 0);
  interpreter();
}

void draw() {} // Don't shoot rays here, processing will go nuts.

void shootrays() {
  println("shoot");

  float k = tan(radians(g_fov) / 2);

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float x_ = (x - (width / 2)) * ((k * 2) / width);
      float y_ = (y - (height / 2)) * ((k * 2) / height);
      float z_ = -1;
      Point e = new Point(0, 0, 0);
      Point s = new Point(x_, y_, z_);
      // println("ray s: " + s.x + " " + s.y + " " + s.z);
      Ray ray = new Ray(e, s);
      set(x, height - y, ray.Trace());
    }
  }

  // some extra anti-aliasing and convolution work im trying
  if (false)
    for (int x = 6; x < width - 6; x++) {
      for (int y = 6; y < height - 6; y++) {
        color c1 = get(x - 1, y - 1);
        color c2 = get(x + 1, y + 1);
        color c3 = get(x - 1, y + 1);
        color c4 = get(x + 1, y - 1);
        color c5 = get(x, y - 1);
        color c6 = get(x, y + 1);
        color c7 = get(x - 1, y);
        color c8 = get(x + 1, y);
        color c9 = get(x, y);

        if (c1 != c9 || c2 != c9 || c3 != c9 || c4 != c9 || c5 != c9 ||
            c6 != c9 || c7 != c9 || c8 != c9) {

          /*
        if (c1 != g_background &&
           c2 != g_background &&
           c3 != g_background &&
           c4 != g_background &&
           c5 != g_background &&
           c6 != g_background &&
           c7 != g_background &&
           c8 != g_background &&
           c9 != g_background) break;
           */

          if (c8 != c9 && true)
            set(x, y,
                color((red(c8) + red(c9)) / 2,

                      (green(c8) + green(c9)) / 2,

                      (blue(c8) + blue(c9)) / 2));

          float rand = random(2);

          if (rand > 1)
            set(x, y,
                color((red(c1) + red(c2) + red(c3) + red(c4) + red(c9)) / 5,

                      (green(c1) + green(c2) + green(c3) + green(c4) +
                       green(c9)) /
                          5,

                      (blue(c1) + blue(c2) + blue(c3) + blue(c4) + blue(c9)) /
                          5));

          if (rand < 1)
            set(x, y,
                color((red(c5) + red(c6) + red(c7) + red(c8) + red(c9)) / 5,

                      (green(c5) + green(c6) + green(c7) + green(c8) +
                       green(c9)) /
                          5,

                      (blue(c5) + blue(c6) + blue(c7) + blue(c8) + blue(c9)) /
                          5));

          /*
        if (c4 != c9 && random(2) > 1)
           set(x+1, y-1, color(
           (red(c1) + red(c2) + red(c3)  +
           red(c4) + red(c5) + red(c6)  +
           red(c7) + red(c8) + red(c9)) / 9,

           (green(c1) + green(c2) + green(c3)  +
           green(c4) + green(c5) + green(c6)  +
           green(c7) + green(c8) + green(c9)) / 9,

           (blue(c1) + blue(c2)  + blue(c3)  +
           blue(c4) + blue(c5)  + blue(c6)  +
           blue(c7) + blue(c8)  + blue(c9)) / 9));



           if (c3 != c9 && random(2) > 1)
           set(x-1, y+1, color(
           (red(c1) + red(c2) + red(c3)  +
           red(c4) + red(c5) + red(c6)  +
           red(c7) + red(c8) + red(c9)) / 9,

           (green(c1) + green(c2) + green(c3)  +
           green(c4) + green(c5) + green(c6)  +
           green(c7) + green(c8) + green(c9)) / 9,

           (blue(c1) + blue(c2)  + blue(c3)  +
           blue(c4) + blue(c5)  + blue(c6)  +
           blue(c7) + blue(c8)  + blue(c9)) / 9));


           if (c2 != c9&& random(2) > 1)
           set(x+1, y+1, color(
           (red(c1) + red(c2) + red(c3)  +
           red(c4) + red(c5) + red(c6)  +
           red(c7) + red(c8) + red(c9)) / 9,

           (green(c1) + green(c2) + green(c3)  +
           green(c4) + green(c5) + green(c6)  +
           green(c7) + green(c8) + green(c9)) / 9,

           (blue(c1) + blue(c2)  + blue(c3)  +
           blue(c4) + blue(c5)  + blue(c6)  +
           blue(c7) + blue(c8)  + blue(c9)) / 9));


           if (c1 != c9&& random(2) > 1)
           set(x-1, y-1, color(
           (red(c1) + red(c2) + red(c3)  +
           red(c4) + red(c5) + red(c6)  +
           red(c7) + red(c8) + red(c9)) / 9,

           (green(c1) + green(c2) + green(c3)  +
           green(c4) + green(c5) + green(c6)  +
           green(c7) + green(c8) + green(c9)) / 9,

           (blue(c1) + blue(c2)  + blue(c3)  +
           blue(c4) + blue(c5)  + blue(c6)  +
           blue(c7) + blue(c8)  + blue(c9)) / 9));



           if (c8 != c9&& false)
           set(x+1, y, color(
           (red(c1) + red(c2) + red(c3)  +
           red(c4) + red(c5) + red(c6)  +
           red(c7) + red(c8) + red(c9)) / 9,

           (green(c1) + green(c2) + green(c3)  +
           green(c4) + green(c5) + green(c6)  +
           green(c7) + green(c8) + green(c9)) / 9,

           (blue(c1) + blue(c2)  + blue(c3)  +
           blue(c4) + blue(c5)  + blue(c6)  +
           blue(c7) + blue(c8)  + blue(c9)) / 9));


           if (c7 != c9&& false)
           set(x-1, y, color(
           (red(c1) + red(c2) + red(c3)  +
           red(c4) + red(c5) + red(c6)  +
           red(c7) + red(c8) + red(c9)) / 9,

           (green(c1) + green(c2) + green(c3)  +
           green(c4) + green(c5) + green(c6)  +
           green(c7) + green(c8) + green(c9)) / 9,

           (blue(c1) + blue(c2)  + blue(c3)  +
           blue(c4) + blue(c5)  + blue(c6)  +
           blue(c7) + blue(c8)  + blue(c8)) / 9));


           if (c5 != c9&& false)
           set(x, y-1, color(
           (red(c1) + red(c2) + red(c3)  +
           red(c4) + red(c5) + red(c6)  +
           red(c7) + red(c8) + red(c9)) / 9,

           (green(c1) + green(c2) + green(c3)  +
           green(c4) + green(c5) + green(c6)  +
           green(c7) + green(c8) + green(c9)) / 9,

           (blue(c1) + blue(c2)  + blue(c3)  +
           blue(c4) + blue(c5)  + blue(c6)  +
           blue(c7) + blue(c8)  + blue(c9)) / 9));

           if (c6 != c9&& false)
           set(x, y+1, color(
           (red(c1) + red(c2) + red(c3)  +
           red(c4) + red(c5) + red(c6)  +
           red(c7) + red(c8) + red(c9)) / 9,

           (green(c1) + green(c2) + green(c3)  +
           green(c4) + green(c5) + green(c6)  +
           green(c7) + green(c8) + green(c9)) / 9,

           (blue(c1) + blue(c2)  + blue(c3)  +
           blue(c4) + blue(c5)  + blue(c6)  +
           blue(c7) + blue(c8)  + blue(c9)) / 9));
           */
        }
      }
    }

  println("shot");
}

public class SurfaceColor {
  public float m_Cdr;
  public float m_Cdg;
  public float m_Cdb;
  public float m_Car;
  public float m_Cag;
  public float m_Cab;
  public float m_Csr;
  public float m_Csg;
  public float m_Csb;
  public float m_phong;
  public float m_reflectance;

  public SurfaceColor(float Cdr, float Cdg, float Cdb, float Car, float Cag,
                      float Cab, float Csr, float Csg, float Csb, float phong,
                      float reflectance) {
    m_Cdr = Cdr;
    m_Cdg = Cdg;
    m_Cdb = Cdb;
    m_Car = Car;
    m_Cag = Cag;
    m_Cab = Cab;
    m_Csr = Csr;
    m_Csg = Csg;
    m_Csb = Csb;
    m_phong = phong;
    m_reflectance = reflectance;
  }

  public float[] Ca() {
    float[] Ca = new float[3];
    Ca[0] = m_Car;
    Ca[1] = m_Cag;
    Ca[2] = m_Cab;
    return Ca;
  }

  public float[] Cr() {
    float[] Cr = new float[3];
    Cr[0] = m_Cdr;
    Cr[1] = m_Cdg;
    Cr[2] = m_Cdb;
    return Cr;
  }

  public float[] Cp() {
    float[] Cp = new float[3];
    Cp[0] = m_Csr;
    Cp[1] = m_Csg;
    Cp[2] = m_Csb;
    return Cp;
  }
}

public abstract class Surface {
  public SurfaceColor m_surface = g_next_surface_color;
  public abstract float Intersect(Ray ray);
  public abstract float[] SurfaceNormal(Ray ray, float t);
}

public class Triangle extends Surface {
  public Point A;
  public Point B;
  public Point C;

  public Triangle(Point A, Point B, Point C) {
    this.A = A;
    this.B = B;
    this.C = C;
  }

  public float Intersect(Ray ray) {
    float a = A.x - B.x;
    float d = A.x - C.x;
    float g = ray.d()[0];
    float j = A.x - ray.m_e[0];
    float b = A.y - B.y;
    float e = A.y - C.y;
    float h = ray.d()[1];
    float k = A.y - ray.m_e[1];
    float c = A.z - B.z;
    float f = A.z - C.z;
    float i = ray.d()[2];
    float l = A.z - ray.m_e[2];

    float M = a * (e * i - h * f) + b * (g * f - d * i) + c * (d * h - e * g);
    float t =
        -(f * (a * k - j * b) + e * (j * c - a * l) + d * (b * l - k * c)) / M;
    float B =
        (j * (e * i - h * f) + k * (g * f - d * i) + l * (d * h - e * g)) / M;
    float y =
        (i * (a * k - j * b) + h * (j * c - a * l) + g * (b * l - k * c)) / M;

    if (t < 0)
      return MAX_FLOAT;
    if (y < 0 || y > 1)
      return MAX_FLOAT;
    if (B < 0 || B > 1 - y)
      return MAX_FLOAT;

    return t;
  }

  public float[] SurfaceNormal(Ray ray, float t) {
    float[] U = Hat(ElementWise(A, B, '-'));
    float[] V = Hat(ElementWise(C, B, '-'));
    return Hat(Cross(U, V));
  }
}

public class Ball extends Surface {
  public Point c;
  public float r;
  public Ball(Point c, float r) {
    this.c = c;
    this.r = r;
  }

  public float Intersect(Ray ray) {
    float[] e_c = ElementWise(ray.m_e, c, '-');
    float[] d = ray.d();
    float ddd = Dot(d, d);
    float dde_c = Dot(d, e_c);

    float descriminant = (dde_c * dde_c) - (ddd * (Dot(e_c, e_c) - (r * r)));

    if (descriminant < 0.0)
      return -1;

    float t_plus = (-dde_c + sqrt(descriminant)) / ddd;
    float t_minus = (-dde_c - sqrt(descriminant)) / ddd;

    float t_closer = min(t_plus, t_minus);
    float t_farther = max(t_plus, t_minus);
    t_closer = 0.0 < t_closer ? t_closer : t_farther;

    if (t_closer <= 0.0)
      return -1;

    return t_closer;
  }

  public float[] SurfaceNormal(Ray ray, float t) {
    return Hat(ElementWise(ray.p(t), c, '-'));
  }
}

public class Point {
  public float x = 0.0;
  public float y = 0.0;
  public float z = 0.0;

  public Point(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public float[] Vector() {
    float[] v = new float[3];
    v[0] = x;
    v[1] = y;
    v[2] = x;
    return v;
  }
}

public class Light extends Point {
  public float r = 0.0;
  public float g = 0.0;
  public float b = 0.0;

  public Light(float x, float y, float z, float r, float g, float b) {
    super(x, y, z);
    this.r = r;
    this.g = g;
    this.b = b;
  }

  public float[] Cl() {
    float[] Cl = new float[3];
    Cl[0] = r;
    Cl[1] = g;
    Cl[2] = b;
    return Cl;
  }

  public float[] l() {
    float[] l = new float[3];
    l[0] = x;
    l[1] = y;
    l[2] = z;
    return l;
  }
}

public class Ray {
  public float[] m_e = new float[3];
  public float[] m_s = new float[3];

  public Ray(Point e, Point s) {
    m_e[0] = e.x;
    m_e[1] = e.y;
    m_e[2] = e.z;
    m_s[0] = s.x;
    m_s[1] = s.y;
    m_s[2] = s.z;
  }

  public Ray(float[] e, float[] s) {
    if (3 != e.length | 3 != s.length)
      ASSERT("Bad length");

    m_e[0] = e[0];
    m_e[1] = e[1];
    m_e[2] = e[2];
    m_s[0] = s[0];
    m_s[1] = s[1];
    m_s[2] = s[2];
  }

  public float[] p(float t) { // e + t(s - e)
    return ElementWise(m_e, ElementWise(t, d(), '*'), '+');
  }

  public float[] d() { return ElementWise(m_s, m_e, '-'); }

  public float[] _d() { return ElementWise(m_e, m_s, '-'); }

  public color Trace() { return Trace(null, 25); }

  public color Trace(Surface avoid_self_reflection, int ttl) {
    if (ttl < 0)
      return g_background;

    boolean hit = false;
    float t = MAX_FLOAT;
    Surface closest_object = null;

    for (int i = 0; i < g_surfaces.size(); i++) {
      Surface current_object = g_surfaces.get(i);
      if (current_object == avoid_self_reflection)
        continue;

      float t_next = current_object.Intersect(this);

      if ((0.0 < t_next) && (t_next < t)) {
        hit = true;
        t = t_next;
        closest_object = current_object;
      }
    }

    if (!hit)
      return g_background;

    float[] p = p(t);
    float[] Ca = closest_object.m_surface.Ca();
    float[] Cr = closest_object.m_surface.Cr();
    float[] Cp = closest_object.m_surface.Cp();
    float[] n = closest_object.SurfaceNormal(this, t);
    float phong = closest_object.m_surface.m_phong;
    float Krefl = closest_object.m_surface.m_reflectance;

    float[] C = Ca;

    for (int i = 0; i < g_lights.size(); i++) {
      float[] Cl = g_lights.get(i).Cl();
      float[] l = Hat(ElementWise(g_lights.get(i).l(), p, '-'));

      Ray shadow_ray = new Ray(p, ElementWise(p, l, '+'));

      boolean shadow_hit = false;
      float shadow_t = MAX_FLOAT;
      for (int j = 0; j < g_surfaces.size(); j++) {
        if (g_surfaces.get(j) == closest_object)
          continue;
        float shadow_t_next = g_surfaces.get(j).Intersect(shadow_ray);

        if ((0.1 < shadow_t_next) && (MAX_FLOAT != shadow_t_next)) {
          shadow_hit = true;
          shadow_t = shadow_t_next;
          // closest_object = current_object;
        }
      }

      if (!shadow_hit) {
        float[] h = Hat(ElementWise(Hat(l), Hat(d()), '-'));

        // book: C = Ca + CrCl max(0, n . l) + ClCp (h . n)^p
        C = ElementWise(C,
                        ElementWise(ElementWise(ElementWise(Cr, Cl, '*'),
                                                max(0, Dot(n, l)), '*'),
                                    ElementWise(ElementWise(Cl, Cp, '*'),
                                                pow(Dot(h, n), phong), '*'),
                                    '+'),
                        '+');

        // notes: C = Ca _ CrCl max(0, n . l) + ClCp (max(0, e . r))^p
        // C =  ElementWise(C, ElementWise( ElementWise( ElementWise(Cr, Cl,
        // '*'), max(0, Dot(n, l)), '*'),
        //                                  ElementWise( ElementWise(Cl, Cp,
        //                                  '*'), pow(max(0, Dot(e, r)), phong),
        //                                  '*'), '+'), '+');
      }
    }

    if (ttl == 0)
      return color(C[0], C[1], C[2]);

    float[] r = Hat(ElementWise(
        Hat(d()),
        ElementWise(ElementWise(2, ElementWise(Hat(d()), n, '*'), '*'), n, '*'),
        '-'));
    Ray recursiveRay = new Ray(p, ElementWise(p, r, '+'));
    color reflected_color = recursiveRay.Trace(closest_object, ttl - 1);
    float[] reflected = new float[3];
    reflected[0] = red(reflected_color);
    reflected[1] = green(reflected_color);
    reflected[2] = blue(reflected_color);

    C = ElementWise(C, ElementWise(Krefl, reflected, '*'), '+');

    return color(C[0], C[1], C[2]);
  }
}

float[] Hat(float[] a) { return ElementWise(a, sqrt(Dot(a, a)), '/'); }

float[] Cross(float[] a, float[] b) { // a X b
  float[] axb = new float[3];
  axb[0] = a[1] * b[2] - a[2] * b[1];
  axb[1] = a[2] * b[0] - a[0] * b[2];
  axb[2] = a[0] * b[1] - a[1] * b[0];
  return axb;
}

float Dot(float[] a, float b[]) {
  float sum = 0.0;
  float[] product = ElementWise(a, b, '*');

  for (int i = 0; i < product.length; i++)
    sum += product[i];

  return sum;
}

float[] ElementWise(Point a, Point b, char op) {
  float[] av = new float[3];
  av[0] = a.x;
  av[1] = a.y;
  av[2] = a.z;

  float[] bv = new float[3];
  bv[0] = b.x;
  bv[1] = b.y;
  bv[2] = b.z;

  return ElementWise(av, bv, op);
}

float[] ElementWise(float[] a, Point b, char op) {
  float[] bv = new float[3];
  bv[0] = b.x;
  bv[1] = b.y;
  bv[2] = b.z;

  return ElementWise(a, bv, op);
}

float[] ElementWise(float b[], float a, char op) {
  float[] av = new float[b.length];

  for (int i = 0; i < av.length; i++)
    av[i] = a;

  return ElementWise(b, av, op);
}

float[] ElementWise(float a, float b[], char op) {
  float[] av = new float[b.length];

  for (int i = 0; i < av.length; i++)
    av[i] = a;

  return ElementWise(av, b, op);
}

float[] ElementWise(float[] a, float b[], char op) {
  if (a.length != b.length)
    ASSERT("Can only add vectors of same length.");

  float[] result = new float[a.length];

  for (int i = 0; i < a.length; i++) {
    switch (op) {
    case '+':
      result[i] = a[i] + b[i];
      break;
    case '-':
      result[i] = a[i] - b[i];
      break;
    case '*':
      result[i] = a[i] * b[i];
      break;
    case '/':
      result[i] = a[i] / b[i];
      break;
    default:
      ASSERT("Unimplemented op: " + op);
    }
  }

  return result;
}

void ASSERT(String str) { println(str); }
