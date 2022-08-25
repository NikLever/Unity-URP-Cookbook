//    Copyright (C) 2020 Ned Makes Games

//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.

//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//    GNU General Public License for more details.

//    You should have received a copy of the GNU General Public License
//    along with this program. If not, see <https://www.gnu.org/licenses/>.

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class BlitMaterialFeature : ScriptableRendererFeature
{
    class RenderPass : ScriptableRenderPass
    {

        private string profilingName;
        private Material material;
        private int materialPassIndex;
        private RTHandle sourceHandle;
        private RTHandle tempTextureHandle;

        public RenderPass(string profilingName, Material material, int passIndex) : base()
        {
            this.profilingName = profilingName;
            this.material = material;
            this.materialPassIndex = passIndex;
            //tempTextureHandle.Init("_TempBlitMaterialTexture");
            tempTextureHandle = RTHandles.Alloc("_TempBlitMaterialTexture", name: "_TempBlitMaterialTexture");
        }

        public void SetSource(RTHandle source)
        {
            this.sourceHandle = source;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(profilingName);

            RenderTextureDescriptor cameraTextureDesc = renderingData.cameraData.cameraTargetDescriptor;
            cameraTextureDesc.depthBufferBits = 0;

            cmd.GetTemporaryRT(Shader.PropertyToID(tempTextureHandle.name), cameraTextureDesc, FilterMode.Bilinear);
            Blit(cmd, sourceHandle, tempTextureHandle, material, materialPassIndex);
            Blit(cmd, tempTextureHandle, sourceHandle);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(Shader.PropertyToID(tempTextureHandle.name));
        }
    }

    [System.Serializable]
    public class Settings
    {
        public Material material;
        public int materialPassIndex = -1; // -1 means render all passes
        public RenderPassEvent renderEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    [SerializeField]
    private Settings settings = new Settings();

    private RenderPass renderPass;

    public Material Material
    {
        get => settings.material;
    }

    public override void Create()
    {
        this.renderPass = new RenderPass(name, settings.material, settings.materialPassIndex);
        renderPass.renderPassEvent = settings.renderEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(renderPass);
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {
        renderPass.SetSource(renderer.cameraColorTargetHandle);  // use of target after allocation
    }
}