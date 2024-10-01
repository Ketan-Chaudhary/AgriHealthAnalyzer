import React, { useState } from "react";
import axios from "axios";

const DiseaseDetectionForm = () => {
  const [image, setImage] = useState(null);
  const [response, setResponse] = useState(null);
  const [error, setError] = useState(null);
  const [imageUrl, setImageUrl] = useState(null);

  const handleChange = (event) => {
    const file = event.target.files[0];
    setImage(file);

    const url = URL.createObjectURL(file);
    setImageUrl(url);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    const formData = new FormData();
    formData.append("images", image);

    try {
      const identifyResponse = await axios.post(
        "http://localhost:5000/api/v3/health_assessment",
        formData,
        {
          headers: {
            "Content-Type": "multipart/form-data",
          },
        }
      );
      setResponse(identifyResponse.data);
      setError(null);
    } catch (err) {
      console.error("Error identifying plant:", err);
      setError(
        "Error identifying plant: " +
          (err.response?.data?.message || err.message)
      );
    }
  };

  const formatResponse = (data) => {
    const cropHealthData = data.healthAssessment;

    return (
      <div className="mt-4 p-6 border border-gray-300 rounded-lg shadow-lg bg-white w-full">
        <h2 className="text-2xl font-bold mb-4 text-gray-800 border-b pb-2 border-gray-300">
          Identification Results
        </h2>
        <div className="text-lg font-semibold text-gray-700 mb-2">
          Diseases:
        </div>
        {cropHealthData.result.disease.suggestions.map((disease) => (
          <div
            key={disease.id}
            className="mb-6 p-4 border-l-4 border-blue-500 bg-blue-50 rounded-lg shadow-sm transition-transform transform hover:scale-105"
          >
            <h3 className="text-lg font-semibold text-blue-600">
              {disease.name}
            </h3>

            <div className="mt-2">
              {/* Local name / common name */}
              <p className="mb-1">
                <strong>Common Name:</strong>{" "}
                {disease.details?.local_name || "N/A"}
              </p>

              {/* Description */}
              <p className="mb-1">
                <strong>Description:</strong>{" "}
                {disease.details?.description || "N/A"}
              </p>

              {/* Link */}
              <p className="mb-1">
                <strong>Link:</strong>{" "}
                {disease.details?.url ? (
                  <a
                    href={disease.details.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-500 underline hover:text-blue-700 transition duration-300"
                  >
                    More info
                  </a>
                ) : (
                  "N/A"
                )}
              </p>

              {/* Treatment: Chemical */}
              <p className="mb-1">
                <strong>Treatment (Chemical):</strong>{" "}
                {disease.details?.treatment?.chemical?.join(", ") || "N/A"}
              </p>

              {/* Treatment: Biological */}
              <p className="mb-1">
                <strong>Treatment (Biological):</strong>{" "}
                {disease.details?.treatment?.biological?.join(", ") || "N/A"}
              </p>

              {/* Treatment: Prevention */}
              <p className="mb-1">
                <strong>Prevention:</strong>{" "}
                {disease.details?.treatment?.prevention?.join(", ") || "N/A"}
              </p>

              {/* Probability */}
              <p className="mb-1">
                <strong>Probability:</strong>{" "}
                {(disease.probability * 100).toFixed(2)}%
              </p>
            </div>
          </div>
        ))}

        {/* Display the uploaded image */}
        {imageUrl && (
          <div className="mt-4">
            <h3 className="text-lg font-semibold text-gray-700">
              Uploaded Image:
            </h3>
            <img
              src={imageUrl}
              alt="Uploaded Plant"
              className="mt-2 rounded-lg shadow-lg transform transition duration-300 hover:scale-105"
            />
          </div>
        )}
      </div>
    );
  };

  return (
    <div className=" mx-auto mt-10 p-6 bg-gray-100 rounded-lg shadow-md">
      <h1 className="text-2xl font-semibold mb-4">Plant Disease Detection</h1>
      <form
        onSubmit={handleSubmit}
        className="max-w-lg flex flex-col m-auto self-center items-center  w-1/2"
      >
        <input
          type="file"
          onChange={handleChange}
          accept="image/*"
          className="border border-gray-300 rounded p-2 mb-4 w-full"
          required
        />
        <button
          type="submit"
          className="w-full bg-blue-500 text-white  font-bold py-2 rounded hover:bg-blue-700 transition duration-300"
        >
          Detect Disease
        </button>
      </form>

      {response && formatResponse(response)}
      {error && <div className="mt-4 text-red-600">{error}</div>}
    </div>
  );
};

export default DiseaseDetectionForm;
