using System;
using UnityEngine;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

namespace GPUInstancedGrass.Common {
	public class GrassField : MonoBehaviour {
		public static int GrassDensity = 250;
		private static bool _performCulling;
		private static event Action UpdateCulling;

		public static bool PerformCulling {
			get => _performCulling;
			set {
				_performCulling = value;
				UpdateCulling?.Invoke();
			}
		}

		[SerializeField]
		private AbstractGrassDrawer _abstractGrassDrawer;
		[FormerlySerializedAs("_size")]
		[SerializeField]
		private Vector2 _fieldSize;

		private Vector2 _cellSize;
		private Camera _camera;
		private Plane _plane;
		private Vector2 _startPosition;

		private void Awake() {
			//Field generation
			_startPosition = -_fieldSize / 2.0f;
			_cellSize = new Vector2(_fieldSize.x / GrassDensity, _fieldSize.y / GrassDensity);
			
			var grassEntities = new Vector2[GrassDensity, GrassDensity];
			var halfCellSize = _cellSize / 2.0f;
		
			for (var i = 0; i < grassEntities.GetLength(0); i++) {
				for (var j = 0; j < grassEntities.GetLength(1); j++) {
					grassEntities[i, j] =
						new Vector2(_cellSize.x * i + _startPosition.x, _cellSize.y * j + _startPosition.y) + new Vector2(
							Random.Range(-halfCellSize.x, halfCellSize.x),
							Random.Range(-halfCellSize.y, halfCellSize.y));
				}
			}
			_abstractGrassDrawer.Init(grassEntities, _fieldSize);
			
			//Culling
			_camera = Camera.main;
			_plane = new Plane(Vector3.up, 0.0f);
			UpdateCameraCells();

			UpdateCulling += UpdateCameraCells;
		}

		private void OnDestroy() {
			UpdateCulling -= UpdateCameraCells;
		}
		
		private void Update() {
			if (_camera.transform.hasChanged) {
				UpdateCameraCells();
			}
		}

		private Vector3 Raycast(Vector3 position) {
			var ray = _camera.ScreenPointToRay(position);
			_plane.Raycast(ray, out var enter);
			return ray.GetPoint(enter);
		}
		
		private void UpdateCameraCells() {
			if (!PerformCulling) {
				_abstractGrassDrawer.UpdatePositions(Vector2Int.zero, new Vector2Int(GrassDensity, GrassDensity));
				return;
			}
			var bottomLeftCameraCorner = Raycast(Vector3.zero);
			var topLeftCameraCorner = Raycast(new Vector3(0.0f, Screen.height));
			var topRightCameraCorner = Raycast(new Vector3(Screen.width, Screen.height));
			var bottomLeftCameraCell = new Vector2Int(
				Mathf.Clamp(Mathf.FloorToInt((topLeftCameraCorner.x - _startPosition.x) / _cellSize.x), 0,
					GrassDensity - 1),
				Mathf.Clamp(Mathf.FloorToInt((bottomLeftCameraCorner.z - _startPosition.y) / _cellSize.y), 0,
					GrassDensity - 1));

			var topRightCameraCell = new Vector2Int(
				Mathf.Clamp(Mathf.FloorToInt((topRightCameraCorner.x - _startPosition.x) / _cellSize.x) + 1, 0,
					GrassDensity - 1),
				Mathf.Clamp(Mathf.FloorToInt((topRightCameraCorner.z - _startPosition.y) / _cellSize.y) + 1, 0,
					GrassDensity - 1));
			_abstractGrassDrawer.UpdatePositions(bottomLeftCameraCell, topRightCameraCell);
		}
	}
}