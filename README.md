# Face Verification SDK

A Flutter SDK for on-device face verification using:

- Google ML Kit — face detection
- ArcFace — face recognition / embedding generation
- `w600k_r50.onnx` — ArcFace ONNX model
- ONNX Runtime — model inference
- Cosine similarity — face matching

The SDK generates a 512-dimensional face embedding from an image and compares it with an enrolled face embedding.

---

## Features

- Face detection
- Face cropping
- Image resizing to 112 × 112
- RGB normalization
- ArcFace embedding generation
- 512-dimensional face embeddings
- Cosine similarity comparison
- Configurable verification threshold
- Enrollment and verification APIs
- On-device inference
- No camera preview is required by the SDK
- Suitable for integration into an existing Flutter application

---

## Architecture

The face verification pipeline is:

```text
Input Image
     │
     ▼
ML Kit Face Detection
     │
     ▼
Face Cropping
     │
     ▼
112 × 112 Resize
     │
     ▼
RGB Normalization
     │
     ▼
ArcFace w600k_r50
     │
     ▼
ONNX Runtime
     │
     ▼
512-Dimensional Embedding
     │
     ▼
Cosine Similarity
     │
     ▼
Verification Result