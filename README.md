# ECG Synthesis

Biomodeling course assignment implementing a **synthetic ECG generator** based on the McSharry et al. (2003) dynamical model. A coupled set of ODEs traces a trajectory around a limit cycle, with each ECG feature (P, Q, R, S, T) modeled as a Gaussian "bump"; the system is integrated with 4th-order Runge-Kutta and driven by a realistic RR-interval (heart-rate variability) process.

## Overview

The program synthesizes a realistic ECG waveform in these stages:

1. **RR / heart-rate variability** — generate an RR-interval power spectrum combining respiratory sinus arrhythmia (RSA, high-frequency) and Mayer-wave (low-frequency) peaks (the "RR Tachogram").
2. **Spectrum → time domain** — apply random phase + inverse Fourier transform (IDFT) to convert the RR spectrum into a time-domain RR signal; scale by a ratio and offset by `rrmean`.
3. **RR peak series** — derive the beat-to-beat R-peak timing from the RR signal.
4. **ECG ODE integration** — integrate the McSharry differential equations with RK4, placing P/Q/R/S/T Gaussians per beat.
5. **Noise + normalization** — add measurement noise (amplitude `A_noise`), then min-max normalize the output.

A GUI exposes per-wave parameters (θᵢ, aᵢ, bᵢ) via scrollbars and plots the RR tachogram, RR process, raw ECG, and normalized ECG.

## ECG background (waveform features)

| Feature | Description | Reported figure |
|---|---|---|
| P wave | Atrial depolarization | amplitude < 0.3 mV, duration < 0.11 s |
| PQ interval | Atrial-depol onset → ventricular-depol onset | — |
| Q wave | Initial QRS downward deflection | ~ −25% of R amplitude *(modeling simplification)* |
| R wave | Tallest peak; marks the heartbeat | max ~3 mV |
| S wave | Negative deflection after R | — |
| QRS complex | Ventricular depolarization | 0.06–0.10 s (avg 0.08 s) |
| ST interval | End of S → start of T | — |
| QT interval | Ventricular depol onset → repol end | increases ~linearly with RR |
| T wave | Ventricular repolarization | amplitude ≥ ~0.1 mV |

## Model

### ECG parameters (Table I) — normal ECG
| Feature (i) | P | Q | R | S | T |
|---|---|---|---|---|---|
| Time (s) | −0.2 | −0.05 | 0 | 0.05 | 0.3 |
| θᵢ (rad) | −π/3 | −π/12 | 0 | π/12 | π/2 |
| aᵢ | 1.2 | −5.0 | 30.0 | −7.5 | 0.75 |
| bᵢ | 0.25 | 0.1 | 0.1 | 0.1 | 0.4 |

In the McSharry model: **θᵢ** = angular position of each feature on the cycle, **aᵢ** = height/amplitude of each Gaussian, **bᵢ** = width/duration of each Gaussian.

### Differential equations
```
ẋ = α·x − ω·y
ẏ = α·y + ω·x
ż = − Σ_{i∈{P,Q,R,S,T}}  aᵢ·Δθᵢ·exp(−Δθᵢ² / (2·bᵢ²))  − (z − z₀)
```
where `Δθᵢ = (θ − θᵢ)` (mod 2π), `ω` is the angular velocity (set by the RR interval), and `z` is the ECG voltage. `z₀` is a slow baseline-wander term. The (x, y) pair moves around a unit limit cycle; each Gaussian pushes `z` up or down as the trajectory passes the corresponding angle.

## Conclusions (as reported)

- Synthesizing an ECG requires morphology-derived parameters; it starts from a frequency-domain RR analysis (RR tachogram) converted to the time domain.
- θᵢ/aᵢ/bᵢ matrices control feature position, height, and width respectively *(see note — the source's conclusion mislabels these)*.
- RK4 (4th order) integrates the ECG differential equations for precision.
- Noise is added because biological signals inherently carry it.

## References

McSharry, P. E., Clifford, G. D., Tarassenko, L., & Smith, L. A. (2003). *A Dynamical Model for Generating Synthetic Electrocardiogram Signals.* IEEE Transactions on Biomedical Engineering, 50(3), 289–294.

---

## Author

**Windy Deftia M**  
Created in: 2018

Biomedical Engineering  
Institut Teknologi Sepuluh Nopember (ITS)