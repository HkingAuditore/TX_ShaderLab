using UnityEditor;
using UnityEngine;

public abstract class ExplosionShaderGUI : ShaderGUI
{
    public MaterialEditor MaterialEditor { get; private set; }
    public MaterialProperty[] Properties { get; private set; }
    public Material TargetMat { get; private set; }
    public string[] KeyWords { get; private set; }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //Init
        MaterialEditor = materialEditor;
        Properties = properties;
        TargetMat = materialEditor.target as Material;
        KeyWords = TargetMat.shaderKeywords;
        ShowGUI();
    }

    protected abstract void ShowGUI();


    #region 简单封装

    protected GUIContent GetGUIContent(string name) => new GUIContent(FindProperty(name, Properties).displayName);

    protected MaterialProperty FindThisProperty(string name) => FindProperty(name, Properties);

    protected GUIContent GetLabel(MaterialProperty property, string tooltip = null) => new GUIContent {text = property.displayName, tooltip = tooltip};

    protected GUIContent GetLabel(string name, string tooltip = null) => new GUIContent {text = name, tooltip = tooltip};

    #endregion


    #region 共用显示

    protected void ShowRenderingSetting()
    {
        GUILayout.Label("渲染设置", EditorStyles.boldLabel);
        MaterialEditor.EnableInstancingField();
        MaterialEditor.DoubleSidedGIField();
        MaterialEditor.RenderQueueField();
    }


    #endregion
}