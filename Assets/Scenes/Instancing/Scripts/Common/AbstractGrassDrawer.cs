using UnityEngine;

namespace GPUInstancedGrass.Common {
	public abstract class AbstractGrassDrawer : MonoBehaviour {
		public abstract void Init(Vector2[,] grassEntities, Vector2 fieldSize);

		public abstract void UpdatePositions(Vector2Int bottomLeftCameraCell, Vector2Int topRightCameraCell);
	}
}