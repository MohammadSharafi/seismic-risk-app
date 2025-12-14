const http = require('http');
const url = require('url');

const PORT = 8080;

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Content-Type': 'application/json',
};

// Mock data storage
const buildings = new Map();
let buildingIdCounter = 1;
const predictions = new Map();

// Parse JSON body
function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (e) {
        resolve({});
      }
    });
    req.on('error', reject);
  });
}

// Helper to send JSON response
function sendJSON(res, statusCode, data) {
  res.writeHead(statusCode, corsHeaders);
  res.end(JSON.stringify(data));
}

const server = http.createServer(async (req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  const method = req.method;

  // Handle CORS preflight
  if (method === 'OPTIONS') {
    res.writeHead(200, corsHeaders);
    res.end();
    return;
  }

  // Buildings endpoints
  if (path.startsWith('/api/v1/buildings')) {
    const match = path.match(/\/api\/v1\/buildings\/(.+)/);
    const id = match ? match[1] : null;

    if (method === 'POST' && !id) {
      // Create building
      const body = await parseBody(req);
      const building = {
        id: `local-${buildingIdCounter++}`,
        latitude: body.latitude || 41.0082,
        longitude: body.longitude || 28.9784,
        addressLine: body.addressLine || '',
        city: body.city || 'Istanbul',
        district: body.district || '',
        neighborhood: body.neighborhood || '',
        postalCode: body.postalCode || '',
        yearBuilt: body.yearBuilt || null,
        numFloors: body.numFloors || null,
        primaryStructureType: body.primaryStructureType || null,
        createdAt: new Date().toISOString(),
      };
      buildings.set(building.id, building);
      sendJSON(res, 201, building);
      return;
    }

    if (method === 'GET' && id) {
      // Get building
      const building = buildings.get(id);
      if (building) {
        sendJSON(res, 200, building);
      } else {
        sendJSON(res, 404, { error: 'Building not found' });
      }
      return;
    }

    if (method === 'PUT' && id) {
      // Update building
      const body = await parseBody(req);
      const building = buildings.get(id);
      if (building) {
        Object.assign(building, body);
        buildings.set(id, building);
        sendJSON(res, 200, building);
      } else {
        sendJSON(res, 404, { error: 'Building not found' });
      }
      return;
    }
  }

  // Predictions endpoints
  if (path.match(/\/api\/v1\/predict\/.+/)) {
    if (method === 'POST') {
      const buildingId = path.split('/').pop();
      const building = buildings.get(buildingId);
      
      if (building) {
        // Return predictionId, client will fetch full prediction
        const predictionId = `pred-${Date.now()}`;
        
        // Generate mock prediction with all required fields
        const prediction = {
          id: predictionId,
          buildingId: buildingId,
          modelVersion: '1.0.0',
          collapseProbability: Math.random() * 0.5 + 0.2, // 0.2 to 0.7
          damageCategory: ['none', 'light', 'moderate', 'severe', 'collapse'][Math.floor(Math.random() * 5)],
          confidence: Math.random() * 0.3 + 0.7, // 0.7 to 1.0
          topFeatures: [
            {
              featureName: 'year_built',
              userFriendlyName: 'Building Age',
              explanation: 'Older buildings tend to have higher risk',
              contribution: 0.35,
            },
            {
              featureName: 'num_floors',
              userFriendlyName: 'Number of Floors',
              explanation: 'Taller buildings may have different risk profiles',
              contribution: 0.28,
            },
            {
              featureName: 'structure_type',
              userFriendlyName: 'Structure Type',
              explanation: 'The structural system affects seismic performance',
              contribution: 0.22,
            },
          ],
          estimatedCasualties: Math.floor(Math.random() * 50),
          retrofitPriorityScore: Math.random(),
          createdAt: new Date().toISOString(),
        };
        predictions.set(predictionId, prediction);
        sendJSON(res, 201, { predictionId: predictionId });
      } else {
        sendJSON(res, 404, { error: 'Building not found' });
      }
      return;
    }
  }

  // Get prediction by ID
  if (path.match(/\/api\/v1\/predictions\/.+/)) {
    if (method === 'GET') {
      const predictionId = path.split('/').pop();
      const prediction = predictions.get(predictionId);
      if (prediction) {
        sendJSON(res, 200, prediction);
      } else {
        sendJSON(res, 404, { error: 'Prediction not found' });
      }
      return;
    }
  }

  // Neighborhood defaults endpoint
  if (path === '/api/v1/neighborhoods/lookup') {
    if (method === 'GET') {
      const lat = parseFloat(parsedUrl.query.lat) || 41.0082;
      const lng = parseFloat(parsedUrl.query.lng) || 28.9784;
      
      sendJSON(res, 200, {
        defaultYearRange: { start: 1980, end: 2000 },
        typicalNumFloorsMean: 5.2,
        typicalStructureType: 'RC_FRAME',
      });
      return;
    }
  }

  // Default 404
  sendJSON(res, 404, { error: 'Not found' });
});

server.listen(PORT, () => {
  console.log(`🚀 Mock backend server running on http://localhost:${PORT}`);
  console.log(`📡 Ready to accept requests from Flutter app`);
});

