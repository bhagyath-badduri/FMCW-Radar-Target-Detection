# FMCW Radar Target Generation and Detection – Signal Processing Pipeline

This repository implements a complete **FMCW (Frequency Modulated Continuous Wave) radar signal processing pipeline** in MATLAB for **target generation, range estimation, and velocity detection**.

The project simulates radar target motion and processes the returned signal to estimate **range and Doppler velocity**, followed by **2D CFAR-based target detection**. These techniques are widely used in **autonomous driving, ADAS systems, and radar-based perception pipelines**.

---

## Project Overview

Modern autonomous systems rely on radar for robust perception under challenging conditions such as:

- low visibility  
- poor lighting  
- adverse weather  

This project implements an end-to-end radar processing pipeline that:

- designs an FMCW waveform based on system specifications  
- simulates a moving target with constant velocity  
- generates transmitted and received radar signals  
- extracts range and velocity information using FFT  
- detects targets using CFAR thresholding  

---

## Sensor Fusion Context

This project forms a critical part of a **sensor fusion perception stack**, where radar is used alongside LiDAR and cameras.

Radar contributes:

- **velocity measurements (Doppler)**  
- robustness to weather and lighting conditions  
- long-range detection capability  

In a complete system, radar outputs can be fused with:

- LiDAR-based obstacle detection  
- camera-based object recognition  
- tracking filters (e.g., Kalman Filter / UKF)

---

## Technical Approach

The pipeline follows standard automotive radar processing steps:

---

### FMCW Waveform Design

Radar parameters are defined based on system requirements:

- carrier frequency (typically 77 GHz)  
- maximum range  
- range resolution  
- maximum velocity  

Using these, the waveform is designed by computing:

- bandwidth  
- chirp time  
- slope of the frequency modulation  

---

### Signal Generation

- Transmitted signal is generated using the FMCW waveform  
- Received signal is simulated by introducing delay based on target distance  
- A moving target model is used to simulate realistic radar returns  

The difference between transmitted and received signals produces the **beat signal**, which encodes range and velocity information.

---

### Range Estimation (1D FFT)

- A **1D Fast Fourier Transform (FFT)** is applied to the beat signal  
- The frequency peak corresponds to the **target range**  

This step converts time-domain data into frequency-domain representation for distance estimation.

---

### Range–Doppler Map (2D FFT)

- A **2D FFT** is applied across:
  - fast time → range  
  - slow time → Doppler  

This produces a **Range–Doppler Map**, where:

- x-axis represents range  
- y-axis represents velocity  

This allows simultaneous estimation of target position and motion.

---

### Target Detection using CFAR

To detect targets in the presence of noise:

- A **2D CFAR (Constant False Alarm Rate)** algorithm is applied  
- Sliding window approach estimates noise from neighboring cells  
- Adaptive thresholding is used to detect valid targets  

This ensures:

- suppression of noise  
- reliable target detection  
- reduced false alarms  

---

## Results & Visualization

The results are visualized using MATLAB-generated plots at each stage of the pipeline.

---

### Range Estimation (1D FFT)

This plot shows the detected target range using a 1D FFT applied to the beat signal.

![Range from First FFT](Range%20from%20First%20FFT.png)

---

### Range–Doppler Map (2D FFT)

This visualization shows both **range and velocity estimation** using a 2D FFT.

![Range Doppler Map](2D%20FFT%20output%20-%20Range%20Doppler%20Map.png)

---

### CFAR Detection Output

This plot shows the final detection after applying CFAR, where noise is suppressed and the target is clearly identified.

![2D CFAR Output](The%20output%20of%20the%202D%20CFAR%20process.png)

---

## Results

The pipeline successfully detects a moving target and estimates:

- accurate range using frequency analysis  
- relative velocity using Doppler shift  
- robust detection using CFAR thresholding  

### Key observations:

- FFT-based processing accurately extracts range information  
- Doppler processing enables velocity estimation  
- CFAR effectively removes noise and false detections  
- The system performs reliably under simulated noisy conditions  

---

## What This Project Demonstrates

This project demonstrates strong understanding of:

- FMCW radar principles  
- signal generation and processing  
- FFT-based frequency analysis  
- Doppler velocity estimation  
- CFAR-based detection  
- radar perception for autonomous systems  

---

## Tools and Environment

- **MATLAB**
- Signal processing techniques  
- FMCW radar theory (77 GHz automotive radar)

---

## Repository Structure

```text
fmcw-radar-target-detection/
│
├── scripts/
│   ├── main.m
│   ├── waveform_generation.m
│   ├── range_fft.m
│   ├── doppler_fft.m
│   └── cfar.m
│
├── Range from First FFT.png
├── 2D FFT output - Range Doppler Map.png
├── The output of the 2D CFAR process.png
├── README.md
└── LICENSE
