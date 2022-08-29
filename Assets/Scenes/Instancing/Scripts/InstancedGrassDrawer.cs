using System.Collections.Generic;
using GPUInstancedGrass.Common;
using UnityEngine;
using UnityEngine.Rendering;

namespace GPUInstancedGrass {
	public class InstancedGrassDrawer : AbstractGrassDrawer {
	
		private static readonly int PositionsShaderProperty = Shader.PropertyToID("PositionsBuffer");

		[SerializeField]
		private Mesh _instanceMesh;
		[SerializeField]
		private Material _instanceMaterial;

		private Bounds _grassBounds;

		private ComputeBuffer _positionBuffer;
		private List<Vector2> _positions;
		private int _positionsCount;
		private Vector2[,] _grassEntities;

		/*private GridCell _bottomLeftCameraCell;
	private GridCell _topRightCameraCell;*/
	
		public override void Init(Vector2[,] grassEntities, Vector2 fieldSize) {
			_grassEntities = grassEntities;
			_grassBounds = new Bounds(transform.position, new Vector3(fieldSize.x, 0.0f, fieldSize.y));
			_positions = new List<Vector2>();
		}
		
		public override void UpdatePositions(Vector2Int bottomLeftCameraCell, Vector2Int topRightCameraCell) {
			_positions.Clear();
			for (var i = bottomLeftCameraCell.x; i < topRightCameraCell.x; i++) {
				for (var j = bottomLeftCameraCell.y; j < topRightCameraCell.y; j++) {
					_positions.Add(_grassEntities[i, j]);
				}
			}

			_positionsCount = _positions.Count;
			_positionBuffer?.Release();
			if (_positionsCount == 0) return;
			_positionBuffer = new ComputeBuffer(_positionsCount, 8);
			_positionBuffer.SetData(_positions);
			_instanceMaterial.SetBuffer(PositionsShaderProperty, _positionBuffer);
		}

		private void Update() {
			if (_positionsCount == 0) return;
			Graphics.DrawMeshInstancedProcedural(_instanceMesh, 0, _instanceMaterial,
				_grassBounds, _positionsCount,
				null, ShadowCastingMode.Off, false);
		}

		private void OnDestroy() {
			_positionBuffer?.Release();
			_positionBuffer = null;
		}
	}
}