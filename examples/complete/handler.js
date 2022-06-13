exports.handler = async function (_event, _context) {
  return {
    isBase64Encoded: false,
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Origin": "*", // Required for CORS support to work
      "Access-Control-Allow-Credentials": true, // Required for cookies, authorization headers with HTTPS
    },
    body: JSON.stringify({ data: "Hello World!" }),
  };
};
