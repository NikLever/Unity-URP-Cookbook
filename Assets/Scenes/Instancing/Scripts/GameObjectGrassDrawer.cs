using GPUInstancedGrass.Common;
using UnityEngine;

namespace GPUInstancedGrass {
	public class GameObjectGrassDrawer : AbstractGrassDrawer {
		[SerializeField]
		private GameObject _grassPrefab;
		
		private GameObject[,] _grassEntities;
		public override void Init(Vector2[,] grassEntities, Vector2 fieldSize) {
			_grassEntities = new GameObject[grassEntities.GetLength(0), grassEntities.GetLength(1)];
			for (var i = 0; i < grassEntities.GetLength(0); i++) {
				for (var j = 0; j < grassEntities.GetLength(1); j++) {
					_grassEntities[i, j] = Instantiate(_grassPrefab,
						new Vector3(grassEntities[i, j].x, 0.0f, grassEntities[i, j].y), Quaternion.identity);
				}
			}
		}

		public override void UpdatePositions(Vector2Int bottomLeftCameraCell, Vector2Int topRightCameraCell) {
			for (var i = 0; i < _grassEntities.GetLength(0); i++) {
				for (var j = 0; j < _grassEntities.GetLength(1); j++) {
					_grassEntities[i, j].SetActive(i >= bottomLeftCameraCell.x && i < topRightCameraCell.x && j >= bottomLeftCameraCell.y &&
					                                  j < topRightCameraCell.y);
				}
			}
		}
	}
}