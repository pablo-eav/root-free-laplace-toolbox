# Root-Free Numerical Laplace Inversion Toolbox for MATLAB & Octave

![Root-Free Laplace Logo](toolbox_logo.png)

[![View on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://es.mathworks.com/matlabcentral/fileexchange/184873-root-free-numerical-laplace-inversion-toolbox)
[![Version](https://img.shields.io/badge/version-1.0.5-blue.svg)](https://github.com/pablo-eav/root-free-numerical-laplace)
[![Platform](https://img.shields.io/badge/platform-MATLAB%20%7C%20Octave-orange.svg)](https://es.mathworks.com/matlabcentral/fileexchange/184873-root-free-numerical-laplace-inversion-toolbox)
[![License](https://img.shields.io/badge/license-BSD--3--Clause-green.svg)](LICENSE)

**Industrial-Grade Numerical Inversion of Massive-Order Transfer Functions Without Root-Finding.**

> [!TIP]
> 🔗 **Official MATLAB Central File Exchange**:  
> [https://es.mathworks.com/matlabcentral/fileexchange/184873-root-free-numerical-laplace-inversion-toolbox](https://es.mathworks.com/matlabcentral/fileexchange/184873-root-free-numerical-laplace-inversion-toolbox)


---

## 🚀 Overview

The **Root-Free Laplace Inversion Toolbox** computes exact time-domain responses $f(z) = \mathcal{L}^{-1}\{F(s)\}$ of massive dynamic systems, rational fractions, resonant networks, and diffusion PDEs directly in standard IEEE-754 `float64` without calculating a single pole or polynomial root.

### Why Root-Free?
- **Bypasses Abel-Ruffini Barriers**: Standard algebraic root solvers (`roots`, `eig`, or symbolic `ilaplace`) fail catastrophically for polynomial degrees $K > 15 \dots 25$.
- **Eliminates High-Precision Bottlenecks**: Unlike classical numerical inversion algorithms (Talbot, Gaver-Stehfest, Euler) that suffer catastrophic numerical cancellation and demand 60–100 decimal digits of multiprecision arithmetic, this toolbox works entirely in native double precision.
- **Scales to Millions of Poles**: Successfully inverts 5,000 undamped resonant modes ($K = 10,000$) in **0.1 seconds** and Chebyshev transmission lines with **$1,000,000$ poles** with $L_\infty$ error $< 10^{-14}$.

---

## 📦 Key Features

1. **6 Specialized Computing Engines**:
   - `Laurent-Stirling (float64)`: Dynamic logarithmic scaling with $O(1)$ cascaded pole detection.
   - `Möbius-Laguerre Conformal`: Maps the open right half-plane $\mathbb{C}^+$ into the unit disk $|w| < 1$, orthogonalizing time responses over $L^2[0, \infty)$.
   - `Adaptive Taylor Extension`: Analytical continuation via overlapping polynomial arcs for large time horizons.
   - `Cauchy-Fujiwara Spectral Bound`: Rigorous $O(K)$ bounding of the pole spectral radius $R_{\text{fuj}}$ and safe causal time horizon $z_{\text{fuj}} = 35 / R_{\text{fuj}}$.
   - `Direct Modal Block`: Matrix-free evaluation for distributed arrays and partial fractions.
   - `Hybrid Dispatcher`: Autonomous engine selection based on relative degree $\delta$, $R_{\text{fuj}}$, and evaluation interval $[z_{\min}, z_{\max}]$.

2. **Native C MEX Acceleration**:
   - Core mathematical recurrences (Favard 3-term Laguerre recurrence, Fujiwara bounds, and synthetic polynomial deconvolution) run in native x86-64 machine code.

3. **Interactive Graphical User Interface (`LaplaceGUI`)**:
   - Complete MATLAB App Designer GUI with live time-domain and logarithmic error displays, engineering presets catalog, and CSV/workspace export.

---

## 📜 Community Edition & Institutional Licensing

The **Root-Free Laplace Inversion Toolbox** is distributed with full Community & Academic access for scientific computing, university research, and engineering simulation.

- **Community & Academic Edition**: Free access under the **BSD 3-Clause License** for open scientific computing, university research, and engineering exploration.
- **Commercial PRO Industrial & Aerospace Licensing**: For corporate deployment, commercial aerospace avionics, downhole petroleum tools (PetroLaplace™ IP Core), proprietary closed-source integration, and priority SLA technical support:

| Tier | Fee | Included Benefits |
| :--- | :---: | :--- |
| **Student / Thesis** | **29 € / year** | Annual support, single workstation, educational thesis projects. |
| **Academic & Faculty Lab** | **129 € / year** | Multi-seat university lab access, academic citation support. |
| **Commercial PRO Industrial** | **299 € / year** | Priority SLA email support, commercial deployment, multi-core C/MEX engine. |
| **Aerospace / Enterprise IP** | *Custom* | DO-178C DAL-A verification artifacts & synthesizable FPGA RTL. |

👉 **[Purchase Commercial License on Official Store (Lemon Squeezy)](https://rootfreelaplace.lemonsqueezy.com/checkout/buy/2b082189-262e-4c99-8ff3-546f4c9b5109?enabled=2159880%2C2159881%2C2159882)**

For custom corporate agreements or enterprise billing:
- **Official Institutional Portal**: [https://presidencialaplaceaerospace.org](https://presidencialaplaceaerospace.org)
- **Direct Contact**: [presidencia@laplaceaerospace.org](mailto:presidencia@laplaceaerospace.org)

---

## ⚡ Quick Start

### 1. Installation
Double-click the official installer package:
```text
root_free_laplace.mltbx
```
Or run the installation script:
```matlab
install_toolbox
```

### 2. Basic Example
```matlab
% Invert second-order underdamped system: F(s) = 1 / (s^2 + 2*s + 2)
z = linspace(0, 10, 200);
f = laplace.invert([1], [1, 2, 2], z);

% Launch the interactive GUI
LaplaceGUI

% Run the comprehensive validation test suite
run_all_tests
```

---

## 📖 Citation & Contact

If you use this toolbox in your scientific research or industrial design, please cite:
```bibtex
@software{Aballe_Laplace_Toolbox_2026,
  author = {Aballe Vázquez, Pablo Enrique},
  title = {{Root-Free Numerical Laplace Inversion Toolbox for MATLAB \& Octave}},
  version = {1.0.5},
  year = {2026},
  url = {https://github.com/pablo-eav/root-free-numerical-laplace}
}
```

- **Author**: Prof. Pablo Enrique Aballe Vázquez
- **Institution**: International Association for Research in Applied Mathematics & Aerospace Physics (Instituto Laplace)
- **Official Portal**: [https://presidencialaplaceaerospace.org](https://presidencialaplaceaerospace.org)
- **Official Contact**: [presidencia@laplaceaerospace.org](mailto:presidencia@laplaceaerospace.org)
- **MATLAB Central File Exchange**: [https://es.mathworks.com/matlabcentral/fileexchange/184873-root-free-numerical-laplace-inversion-toolbox](https://es.mathworks.com/matlabcentral/fileexchange/184873-root-free-numerical-laplace-inversion-toolbox)
- **GitHub Repository**: [https://github.com/pablo-eav/root-free-numerical-laplace](https://github.com/pablo-eav/root-free-numerical-laplace)

