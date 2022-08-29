using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace GPUInstancedGrass {
	public class BackToMainButton : MonoBehaviour{
		private void Awake() {
			GetComponent<Button>().onClick.AddListener(() => { SceneManager.LoadScene(0);});
		}
	}
}