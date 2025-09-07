#!/bin/sh

set -e

echo "🚀 Starting smart contract deployment..."

# Wait for geth-init to complete prefunding
echo "⏳ Waiting for geth-init to complete prefunding..."
until [ -f "/shared/geth-init-complete" ]; do
  echo "Waiting for geth-init-complete file..."
  sleep 1
done
echo "✅ Prefunding completed, proceeding with deployment..."

# Clean up and clone repository fresh
echo "🧹 Cleaning up previous repository..."
rm -rf /workspace/cohort-1-assignments-public

cd /workspace

echo "📥 Cloning repository..."
if [ -d "cohort-1-assignments-public" ]; then
    echo "Repository already exists, pulling latest changes..."
    cd cohort-1-assignments-public
    git pull origin main
else
    git clone https://github.com/gjwnsdud2083/cohort-1-assignments-public.git
    cd cohort-1-assignments-public
fi

# Navigate to the 1a directory
cd 1a

# Install dependencies
echo "📦 Installing dependencies..."
forge install

# Build the project
echo "🔨 Building project..."
forge build

# Deploy the contracts and save logs
echo "🚀 Deploying MiniAMM contracts..."
forge script script/MiniAMM.s.sol:MiniAMMScript \
    --rpc-url http://geth:8545 \
    --private-key be44593f36ac74d23ed0e80569b672ac08fa963ede14b63a967d92739b0c8659 \
    --broadcast > deployment.log 2>&1

echo "✅ Deployment completed!"

# Create deployment.json file
echo "📝 Creating deployment.json file..."

# Extract contract addresses from logs using grep and sed
echo "🔍 Extracting contract addresses from deployment logs..."

# Extract addresses from console.log output
TOKEN0_ADDRESS=$(grep "Token0.*deployed:" deployment.log | sed 's/.*deployed: \(0x[a-fA-F0-9]*\).*/\1/')
TOKEN1_ADDRESS=$(grep "Token1.*deployed:" deployment.log | sed 's/.*deployed: \(0x[a-fA-F0-9]*\).*/\1/')
MINIAMM_ADDRESS=$(grep "MiniAMM.*deployed:" deployment.log | sed 's/.*deployed: \(0x[a-fA-F0-9]*\).*/\1/')

# Verify addresses were extracted
if [ -z "$TOKEN0_ADDRESS" ] || [ -z "$TOKEN1_ADDRESS" ] || [ -z "$MINIAMM_ADDRESS" ]; then
    echo "❌ Failed to extract contract addresses from deployment logs"
    echo "Token0: $TOKEN0_ADDRESS"
    echo "Token1: $TOKEN1_ADDRESS"
    echo "MiniAMM: $MINIAMM_ADDRESS"
    echo "📄 Deployment log content:"
    cat deployment.log
    exit 1
fi

echo "✅ Contract addresses extracted:"
echo "   Token0: $TOKEN0_ADDRESS"
echo "   Token1: $TOKEN1_ADDRESS"
echo "   MiniAMM: $MINIAMM_ADDRESS"

# Create JSON file with extracted addresses
cat > /workspace-root/example-deployment.json << EOF
{
    "mock_erc_0": "$TOKEN0_ADDRESS",
    "mock_erc_1": "$TOKEN1_ADDRESS",
    "mini_amm": "$MINIAMM_ADDRESS"
}
EOF

echo "✅ example-deployment.json file created successfully!"
echo "📊 Contract addresses saved to /workspace-root/example-deployment.json"
