import React from "react";
import DiseaseDetectionForm from "./components/DiseaseDetectionForm";
const App = () => {
  return (
    <div>
      <h1 className="text-2xl font-bold text-white bg-blue-500 p-4">
        Crop Idenfication & Disease Detection
      </h1>
      <DiseaseDetectionForm />
    </div>
  );
};

export default App;
