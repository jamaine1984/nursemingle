#!/bin/bash

echo "🧪 Testing API endpoints..."

# Test the auth register endpoint
echo "📝 Testing /auth/register endpoint..."
curl -X POST http://178.156.173.172/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo "🔐 Testing /auth/login endpoint..."
curl -X POST http://178.156.173.172/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo "🏥 Testing health endpoint..."
curl -X GET http://178.156.173.172/health \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo "✅ API testing complete!" 