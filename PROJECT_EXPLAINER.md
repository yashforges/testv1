# VQA Modal Analysis — Project Overview & Technical Explainer

> **Technical Summary:**  
> This research project investigates the application of hybrid classical-quantum algorithms (specifically the Variational Quantum Eigensolver, VQE) to the structural generalized eigenvalue problem:
> $$\mathbf{K} \boldsymbol{\phi} = \omega^2 \mathbf{M} \boldsymbol{\phi}$$
> for discretized elastodynamic continuum structures (Euler-Bernoulli beams, 1D/2D trusses).
>
> 📍 **Context:** Academic research originating at COEP Technological University, exploring structural mechanics formulations on simulated parameterized quantum circuits.

---

## 1. The Engineering Formulation

In structural dynamics, natural frequencies ($\omega_i$) and vibration mode shapes ($\boldsymbol{\phi}_i$) describe the resonant characteristics of mechanical and civil structures:
- $\mathbf{K} \in \mathbb{R}^{D \times D}$: Global stiffness matrix (symmetric positive definite after kinematic boundary conditions).
- $\mathbf{M} \in \mathbb{R}^{D \times D}$: Global consistent mass matrix (symmetric positive definite).
- $\omega_i$: $i$-th undamped natural circular frequency (rad/s).
- $\boldsymbol{\phi}_i$: $i$-th modal eigenvector defining relative nodal displacement and rotation.

### 1.1 Structural Health Monitoring (SHM) Context
Localized structural damage (e.g., fatigue cracking, corrosion) reduces elemental stiffness ($k_e \to (1 - d_e) k_e$). This degradation manifests as downward shifts in natural frequencies ($\Delta \omega_i < 0$). By observing these shifts, an inverse problem can be formulated to locate the damaged element:
$$\Delta \boldsymbol{\omega} \approx \mathbf{S} \mathbf{d}$$
where $\mathbf{S}_{ij} = \frac{\partial \omega_i}{\partial d_j}$ is the classical first-order modal sensitivity matrix.

---

## 2. Classical Solvers vs. Quantum Formulation: A Fair Comparison

### 2.1 The Reality of Classical Solvers
Classical structural finite element analysis rarely uses dense $O(D^3)$ matrix diagonalization. In engineering practice:
- Structural FEA matrices are **narrowly banded and sparse** ($\text{nnz}(K) \approx \mathcal{O}(D)$).
- Classical sparse iterative eigensolvers (e.g., **Lanczos algorithm**, **ARPACK**, or shift-and-invert spectral transformations) compute the lowest $k$ modes in:
  $$\mathcal{O}(k \cdot \text{nnz}(\mathbf{K})) \approx \mathcal{O}(k \cdot D) \text{ operations}$$
- For systems with $D = 4$ to $64$ degrees of freedom, classical sparse solvers execute in **less than 1 millisecond** with machine precision ($r_i < 10^{-11}$).
- Therefore, VQE does **not** provide a commercial computational speedup on today's hardware or for small-to-moderate engineering discretizations. The value of this work lies in foundational formulation research for future quantum hardware.

### 2.2 Quantum Variational Representation & Resource Overheads
A quantum register of $n = \lceil \log_2 D \rceil$ qubits represents a state vector $|\psi\rangle$ of dimension $D = 2^n$. However, this logarithmic state compression comes with distinct quantum resource overheads:
1. **Pauli Decomposition Overhead:**
   FEA operators $\mathbf{K}$ and $\mathbf{M}$ must be expanded into sums of Pauli strings:
   $$\mathbf{K} = \sum_{k=1}^{M_K} c_k \mathcal{P}_k, \quad \mathbf{M} = \sum_{j=1}^{M_M} d_j \mathcal{Q}_j$$
   While sparse, this decomposition generates $\mathcal{O}(N \log N)$ to $\mathcal{O}(N^2)$ Pauli terms that must be measured independently or in commuting cliques.
2. **Measurement Shot Complexity:**
   Estimating quantum observables to precision $\epsilon$ requires $S \sim \mathcal{O}\left(\frac{(\sum |c_k|)^2}{\epsilon^2}\right)$ measurement shots. For sub-percent structural frequency precision, this requires $10^5$ to $10^6$ total shots per optimization iteration.
3. **Iterative Optimization:**
   Variational parameters are updated through classical non-linear optimization loops (e.g., L-BFGS-B, SPSA), requiring dozens to hundreds of circuit executions per eigenvalue solve.

---

## 3. Investigated Technical Hypotheses

This project investigates three specific algorithmic formulations:

### 3.1 Generalized Rayleigh Quotient Formulation
- **Conventional Quantum Approach:** Solves standard Hermitian problem $\mathbf{H}|\psi\rangle = \lambda|\psi\rangle$ by classically computing $\mathbf{H} = \mathbf{M}^{-1/2}\mathbf{K}\mathbf{M}^{-1/2}$. This introduces large Pauli coefficients ($\sum |c| \sim 10^9$) due to stiffness-to-mass spectral scaling ($\|K\|/\|M\| \approx 10^9$).
- **Generalized Rayleigh Formulation:** Directly optimizes the ratio of expectation values:
  $$R(\boldsymbol{\theta}) = \frac{\langle \psi(\boldsymbol{\theta}) | \widetilde{\mathbf{K}} | \psi(\boldsymbol{\theta}) \rangle}{\langle \psi(\boldsymbol{\theta}) | \widetilde{\mathbf{M}} | \psi(\boldsymbol{\theta}) \rangle} \cdot \frac{\|\mathbf{K}\|_2}{\|\mathbf{M}\|_2}$$
  Both operators are normalized independently ($\|\widetilde{\mathbf{K}}\|_2 \le 1, \|\widetilde{\mathbf{M}}\|_2 \le 1$).
- **Verified Finding:** Reduces estimator variance by $3.35\times$ (at $16k$ shots) and $6.96\times$ (at $65k$ shots) compared to direct $\mathbf{M}^{-1/2}\mathbf{K}\mathbf{M}^{-1/2}$ measurement. However, at low shot budgets ($\le 1024$ shots), ratio denominator fluctuations degrade stability.

### 3.2 Parity-Subspace Confinement ($T_{\text{mech}}$)
- **Continuum Symmetry:** A symmetric beam exhibits reflection parity where translational displacement has even parity ($u(x) = u(L-x)$) and rotational slope has odd parity ($\theta(x) = -\theta(L-x)$).
- **Subspace Circuit:** By diagonalizing the discrete reflection operator $T_{\text{mech}}$ into a change-of-basis matrix $V_{\text{mech}}$, the parity is mapped onto a single designated control qubit ($|0\rangle$ for Even, $|1\rangle$ for Odd).
- **Verified Finding:** Guarantees $0.000000\%$ unphysical state leakage by construction on symmetric reference configurations and restores $100\%$ convergence across 2, 3, 4 qubits.
- **Known Limitation:** Localized or asymmetric damage breaks spatial reflection symmetry ($[\mathbf{K}_d, T_{\text{mech}}] \neq 0$). The symmetry constraint is therefore valid for healthy baseline characterization, while asymmetric damage requires relaxed parameterization.

### 3.3 Multi-Modal Inverse Damage Localization
- **Sensitivity Inversion:** Single-crack damage is localized by solving regularized non-negative least squares $\min_{\mathbf{d} \ge 0} \|\mathbf{S}\mathbf{d} - \Delta\hat{\boldsymbol{\omega}}\|_2^2 + \lambda \|\mathbf{d}\|_2^2$.
- **Verified Finding:** Mode 1 is sensitive to mid-span bending; Mode 2 is sensitive to near-support curvature. Combining both modes yields $93.4\% - 100\%$ single-crack localization accuracy under realistic shot noise.
- **Known Limitation:** With only two measured modes, simultaneous multi-crack localization (dual cracks) is rank-deficient and requires extracting Mode 3 and Mode 4.
