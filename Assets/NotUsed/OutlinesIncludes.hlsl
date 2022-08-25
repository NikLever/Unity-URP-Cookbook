// MIT License

// Copyright (c) 2020 NedMakesGames

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#ifndef SOBELOUTLINES_INCLUDED
#define SOBELOUTLINES_INCLUDED

#include "DecodeDepthNormals.hlsl"

TEXTURE2D(_DepthNormalsTexture); SAMPLER(sampler_DepthNormalsTexture);

// The sobel effect runs by sampling the texture around a point to see
// if there are any large changes. Each sample is multiplied by a convolution
// matrix weight for the x and y components seperately. Each value is then
// added together, and the final sobel value is the length of the resulting float2.
// Higher values mean the algorithm detected more of an edge

// These are points to sample relative to the starting point
static float2 sobelSamplePoints[9] = {
    float2(-1, 1), float2(0, 1), float2(1, 1),
    float2(-1, 0), float2(0, 0), float2(1, 0),
    float2(-1, -1), float2(0, -1), float2(1, -1),
};

// Weights for the x component
static float sobelXMatrix[9] = {
    1, 0, -1,
    2, 0, -2,
    1, 0, -1
};

// Weights for the y component
static float sobelYMatrix[9] = {
    1, 2, 1,
    0, 0, 0,
    -1, -2, -1
};

// This function runs the sobel algorithm over the depth texture
void DepthSobel_float(float2 UV, float Thickness, out float Out) {
    float2 sobel = 0;
    // We can unroll this loop to make it more efficient
    // The compiler is also smart enough to remove the i=4 iteration, which is always zero
    [unroll] for (int i = 0; i < 9; i++) {
        float depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV + sobelSamplePoints[i] * Thickness);
        sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);
    }
    // Get the final sobel value
    Out = length(sobel);
}

// Sample the depth normal map and decode depth and normal from the texture
void GetDepthAndNormal(float2 uv, out float depth, out float3 normal) {
    float4 coded = SAMPLE_TEXTURE2D(_DepthNormalsTexture, sampler_DepthNormalsTexture, uv);
    DecodeDepthNormal(coded, depth, normal);
}

// A wrapper around the above function for use in a custom function node
void CalculateDepthNormal_float(float2 UV, out float Depth, out float3 Normal) {
    GetDepthAndNormal(UV, Depth, Normal);
    // Normals are encoded from 0 to 1 in the texture. Remap them to -1 to 1 for easier use in the graph
    Normal = Normal * 2 - 1;
}

void NormalsSobel_float(float2 UV, float Thickness, out float Out) {
    // We have to run the sobel algorithm over the XYZ channels separately, like color
    float2 sobelX = 0;
    float2 sobelY = 0;
    float2 sobelZ = 0;
    // We can unroll this loop to make it more efficient
    // The compiler is also smart enough to remove the i=4 iteration, which is always zero
    [unroll] for (int i = 0; i < 9; i++) {
        float depth;
        float3 normal;
        GetDepthAndNormal(UV + sobelSamplePoints[i] * Thickness, depth, normal);
        // Create the kernel for this iteration
        float2 kernel = float2(sobelXMatrix[i], sobelYMatrix[i]);
        // Accumulate samples for each coordinate
        sobelX += normal.x * kernel;
        sobelY += normal.y * kernel;
        sobelZ += normal.z * kernel;
    }
    // Get the final sobel value
    // Combine the XYZ values by taking the one with the largest sobel value
    Out = max(length(sobelX), max(length(sobelY), length(sobelZ)));
}

void ViewDirectionFromScreenUV_float(float2 In, out float3 Out) {
    // Code by Keijiro Takahashi @_kzr and Ben Golus @bgolus
    // Get the perspective projection
    float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
    // Convert the uvs into view space by "undoing" projection
    Out = -normalize(float3((In * 2 - 1) / p11_22, -1));
}

#endif