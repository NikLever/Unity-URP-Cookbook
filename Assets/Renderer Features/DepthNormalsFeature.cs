// MIT License

// Copyright (c) 2020 NedMakesGames
// Adapted 2022 Nik Lever

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

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class DepthNormalsFeature : ScriptableRendererFeature
{
    class RenderPass : ScriptableRenderPass
    {

        private Material material;
        private RTHandle destinationHandle;
        private List<ShaderTagId> shaderTags;
        private FilteringSettings filteringSettings;
        string profilerTag = "DepthNormals Prepass";

        public RenderPass(Material material) : base()
        {
            this.material = material;
            // This contains a list of shader tags. The renderer will only render objects with
            // materials containing a shader with at least one tag in this list
            this.shaderTags = new List<ShaderTagId>() {
                new ShaderTagId("DepthOnly"),
                //new ShaderTagId("SRPDefaultUnlit"),
                //new ShaderTagId("UniversalForward"),
                //new ShaderTagId("LightweightForward"),
            };
            // Render opaque materials
            this.filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
            //destinationHandle.Init("_DepthNormalsTexture");
            destinationHandle = RTHandles.Alloc("_CameraDepthNormalsTexture", name: "_CameraDepthNormalsTexture");
        }

        // Configure the pass by creating a temporary render texture and
        // readying it for rendering
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            //cmd.GetTemporaryRT(destinationHandle.id, cameraTextureDescriptor, FilterMode.Point);
            //ConfigureTarget(destinationHandle.Identifier());
            cmd.GetTemporaryRT(Shader.PropertyToID(destinationHandle.name), cameraTextureDescriptor, FilterMode.Point);
            ConfigureTarget(destinationHandle);
            ConfigureClear(ClearFlag.All, Color.black);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {

            /* // Create the draw settings, which configures a new draw call to the GPU
             var drawSettings = CreateDrawingSettings(shaderTags, ref renderingData, renderingData.cameraData.defaultOpaqueSortFlags);
             // We cant to render all objects using our material
             drawSettings.overrideMaterial = material;
             context.DrawRenderers(renderingData.cullResults, ref drawSettings, ref filteringSettings);*/
            CommandBuffer cmd = CommandBufferPool.Get(profilerTag);

           // using (new ProfilingScope(cmd, new ProfilingSampler(profilerTag)))
            //{
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                var sortFlags = renderingData.cameraData.defaultOpaqueSortFlags;
                var drawSettings = CreateDrawingSettings(shaderTags, ref renderingData, sortFlags);
                drawSettings.perObjectData = PerObjectData.None;


                ref CameraData cameraData = ref renderingData.cameraData;
                Camera camera = cameraData.camera;
                //if (cameraData.isStereoEnabled)
                    //context.StartMultiEye(camera);


                drawSettings.overrideMaterial = material;


                context.DrawRenderers(renderingData.cullResults, ref drawSettings,
                    ref filteringSettings);

                cmd.SetGlobalTexture("_CameraDepthNormalsTexture", Shader.PropertyToID(destinationHandle.name));
            //}

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            //cmd.ReleaseTemporaryRT(destinationHandle.id);
            cmd.ReleaseTemporaryRT(Shader.PropertyToID(destinationHandle.name));
        }
    }

    private RenderPass renderPass;

    public override void Create()
    {
        // We will use the built-in renderer's depth normals texture shader
        Material material = CoreUtils.CreateEngineMaterial("Hidden/Internal-DepthNormalsTexture");
        this.renderPass = new RenderPass(material);
        // Render after shadow caster, depth, etc. passes
        renderPass.renderPassEvent = RenderPassEvent.AfterRenderingPrePasses;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(renderPass);
    }
}
