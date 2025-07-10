import { useState } from "react";
import axios from "axios";

export default function Home() {
  const [file, setFile] = useState<File | null>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFile(e.target.files[0]);
    }
  };

  const handleUpload = async () => {
    if (!file) return;

    const formData = new FormData();
    formData.append("file", file);

    await axios.post("/api/upload", formData);
  };

  return (
    <div className="p-4">
      <h1 className="text-xl mb-4">Upload File to AWS S3</h1>
      <input type="file" onChange={handleFileChange} placeholder="Browse..."/>
      <button onClick={handleUpload} className="ml-2 bg-blue-500 text-white p-2">Upload</button>
    </div>
  );
}