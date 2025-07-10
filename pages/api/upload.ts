import type { NextApiRequest, NextApiResponse } from 'next';
import AWS from 'aws-sdk';
import formidable from 'formidable';
import fs from 'fs';
import mysql from 'mysql2/promise';

export const config = {
  api: {
    bodyParser: false,
  },
};

const s3 = new AWS.S3({
    region: process.env.AWS_REGION,
});

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const form = new formidable.IncomingForm();

  form.parse(req, async (err, fields, files) => {
    if (err || !files.file) return res.status(400).json({ error: "File upload error." });

    const file = Array.isArray(files.file) ? files.file[0] : files.file;
    const fileContent = fs.readFileSync(file.filepath);

    const uploadResult = await s3
      .upload({
        Bucket: process.env.AWS_BUCKET_NAME!,
        Key: file.originalFilename!,
        Body: fileContent,
      })
      .promise();

    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASS,
      database: process.env.DB_NAME,
    });

    await connection.execute(
      "INSERT INTO uploads (filename, s3_url) VALUES (?, ?)",
      [file.originalFilename, uploadResult.Location]
    );

    await connection.end();

    res.status(200).json({ message: "File uploaded successfully." });
  });
}