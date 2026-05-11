from flask import Flask, request, jsonify, send_from_directory
import torch
import torch.nn as nn
import numpy as np
import os

app = Flask(__name__)

# --- Define your model architecture (adjust if different) ---
class DiabetesModel(nn.Module):
    def __init__(self):
        super(DiabetesModel, self).__init__()
        self.net = nn.Sequential(
            nn.Linear(8, 16),
            nn.ReLU(),
            nn.Linear(16, 8),
            nn.ReLU(),
            nn.Linear(8, 1),
            nn.Sigmoid()
        )

    def forward(self, x):
        return self.net(x)

# --- Load model ---
model = DiabetesModel()
model.load_state_dict(torch.load("diabetes.pt", map_location="cpu"))
model.eval()

# --- Serve frontend HTML ---
@app.route("/")
def index():
    return send_from_directory(".", "Medicore_AI.html")

# --- Prediction endpoint ---
@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.json
        # Expected: {"features": [pregnancies, glucose, bp, skin, insulin, bmi, dpf, age]}
        features = data["features"]
        tensor = torch.tensor([features], dtype=torch.float32)
        with torch.no_grad():
            output = model(tensor)
        prob = output.item()
        result = "Diabetic" if prob >= 0.5 else "Non-Diabetic"
        return jsonify({"prediction": result, "probability": round(prob, 4)})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# --- Health check ---
@app.route("/health")
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
