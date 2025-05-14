#!/bin/bash
set -uxe

BUILD_DIR=dist-standalone

mkdir -p $BUILD_DIR 2>/dev/null || true

# Create proto descriptor set.
mkdir -p $BUILD_DIR/proto
npx grpc_tools_node_protoc \
  --proto_path=proto \
  --descriptor_set_out=$BUILD_DIR/proto/descriptor_set.pb \
  --include_imports \
  proto/*.proto

# Generate the code to setup the gRPC handlers.
NODE_OPTIONS=--no-warnings node standalone/generate-server-setup.js

# Compile the standalone extension.
npm run compile-standalone

# # Copy the standalone's package.json and vscode replacement module into the build dir.
cp -av standalone/runtime-files/. $BUILD_DIR

cd $BUILD_DIR

# Zip all the files needed for the standalone extension.
zip -q -r standalone.zip . -x standalone.zip

echo Built standalone cline: $(realpath standalone.zip)
