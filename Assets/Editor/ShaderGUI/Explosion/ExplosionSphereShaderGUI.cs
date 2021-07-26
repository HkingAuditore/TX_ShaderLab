using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Graphs;
using UnityEngine;
enum RotationType {
    UseOffset,UseSpeed
}
public class ExplosionSphereShaderGUI : ShaderGUI
{
    private MaterialEditor _materialEditor; //当前材质面板
    private MaterialProperty[] _properties; //当前shader的properties

    private Material _targetMat; //绘制对象材质球
    private string[] _keyWords; //当前shader keywords

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //Init
        this._materialEditor = materialEditor;
        this._properties = properties;
        this._targetMat = materialEditor.target as Material;
        this._keyWords = this._targetMat.shaderKeywords;
        ShowGUI();
    }

    private void ShowGUI()
    {
        // base.OnGUI (materialEditor, properties);
        ShowMain();
        GUILayout.Space(15);
        ShowTransition();
        GUILayout.Space(15);
        ShowFresnel();
        
        GUILayout.Space(15);
        GUILayout.Label("渲染设置", EditorStyles.boldLabel);
        _materialEditor.EnableInstancingField();
        _materialEditor.DoubleSidedGIField();
        _materialEditor.RenderQueueField();
    }

    private GUIContent GetGUIContent(String name) => new GUIContent(FindProperty(name, _properties).displayName);
    private MaterialProperty FindThisProperty(String name) => FindProperty(name, this._properties);
    private GUIContent GetLabel(MaterialProperty property, string tooltip = null) =>
        new GUIContent {text = property.displayName, tooltip = tooltip};
    private GUIContent GetLabel(string name, string tooltip = null) => new GUIContent {text = name, tooltip = tooltip};
    //抄这个https://blog.csdn.net/enk_2/article/details/109236874

    private void ShowFresnel()
    {
        EditorGUI.BeginChangeCheck();
        bool USE_FRESNEL  = Array.IndexOf(this._keyWords, "USE_FRESNEL") != -1;
        var origFontStyle = EditorStyles.label.fontStyle;
        EditorStyles.label.fontStyle = FontStyle.Bold;
        USE_FRESNEL  = EditorGUILayout.Toggle("边缘光", USE_FRESNEL , EditorStyles.toggle);
        EditorStyles.label.fontStyle = origFontStyle;
        
        if (USE_FRESNEL)
        {
            EditorGUILayout.BeginVertical("box");
            
            MaterialProperty fresnelIntensity = FindThisProperty("_FresnelIntensity");
            MaterialProperty fresnelSize = FindThisProperty("_FresnelSize");
            MaterialProperty fresnelColor = FindThisProperty("_FresnelColor");

            _materialEditor.ShaderProperty(fresnelColor,GetLabel("边缘光颜色"));
            _materialEditor.ShaderProperty(fresnelIntensity,GetLabel("边缘光强度"));
            _materialEditor.ShaderProperty(fresnelSize,GetLabel("边缘光尺寸"));

            EditorGUILayout.EndVertical();
        }

        
        if (EditorGUI.EndChangeCheck())
        {
            if (USE_FRESNEL)
                _targetMat.EnableKeyword("USE_FRESNEL");
            else
                _targetMat.DisableKeyword("USE_FRESNEL");
        }

    }

    private void ShowMain()
    {
        EditorGUI.BeginChangeCheck();

        GUILayout.Label("基本", EditorStyles.boldLabel);
        MaterialProperty tex0 = FindThisProperty("_Tex0");
        MaterialProperty tex0Ramp = FindThisProperty("_Tex0Ramp");
        MaterialProperty color = FindThisProperty("_Color0");
        MaterialProperty burnTex = FindThisProperty("_BurnTex");
        MaterialProperty cutoff = FindThisProperty("_Cutoff");
            
        _materialEditor.TexturePropertySingleLine(GetLabel("主贴图"), tex0);
        _materialEditor.TexturePropertySingleLine(GetLabel("颜色采样"), tex0Ramp, color);
        _materialEditor.TexturePropertySingleLine(GetLabel("溶解"), burnTex, cutoff);


        GUILayout.Space(10);
        GUILayout.Label("旋转", EditorStyles.boldLabel);
        bool USE_OFFSET = _targetMat.IsKeywordEnabled("USE_OFFSET");
        RotationType rotationType = USE_OFFSET ? RotationType.UseOffset : RotationType.UseSpeed;
        rotationType = (RotationType)EditorGUILayout.Popup("旋转操作单位", (int)rotationType,new string[]{"旋转量","旋转速度"});
        switch (rotationType)
        {
            case RotationType.UseOffset:
                MaterialProperty rotation = FindThisProperty("_Rotation");
                _materialEditor.ShaderProperty(rotation,GetLabel("旋转量"));
                break;
            case RotationType.UseSpeed:
                MaterialProperty rotationSpeed = FindThisProperty("_RotateSpeed");
                _materialEditor.ShaderProperty(rotationSpeed,GetLabel("旋转速度"));

                break;
            default:
                throw new ArgumentOutOfRangeException();
        }
        if (EditorGUI.EndChangeCheck())
        {
            _materialEditor.RegisterPropertyChangeUndo("旋转操作单位");
            switch (rotationType)
            {
                case RotationType.UseOffset:
                    _targetMat.EnableKeyword("USE_OFFSET");
                    break;
                case RotationType.UseSpeed:
                    _targetMat.DisableKeyword("USE_OFFSET");
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

        }

    }

    private void ShowTransition()
    {
        EditorGUI.BeginChangeCheck();
        bool USE_TRANSITION = Array.IndexOf(this._keyWords, "USE_TRANSITION") != -1;
        var origFontStyle = EditorStyles.label.fontStyle;
        EditorStyles.label.fontStyle = FontStyle.Bold;
        USE_TRANSITION = EditorGUILayout.Toggle("渐变", USE_TRANSITION, EditorStyles.toggle);
        EditorStyles.label.fontStyle = origFontStyle;
        
        if (USE_TRANSITION)
        {
            _targetMat.EnableKeyword("USE_TRANSITION");
            EditorGUILayout.BeginVertical("box");

            MaterialProperty tex1 = FindThisProperty("_Tex1");
            MaterialProperty tex1Ramp = FindThisProperty("_Tex1Ramp");
            MaterialProperty transitionTex = FindThisProperty("_TransitionTex");
            MaterialProperty color = FindThisProperty("_Color1");
            MaterialProperty transition = FindThisProperty("_Transition");

            _materialEditor.TexturePropertySingleLine(GetLabel("渐变目标贴图"), tex1);
            _materialEditor.TexturePropertySingleLine(GetLabel("渐变颜色采样"), tex1Ramp, color);
            _materialEditor.TexturePropertySingleLine(GetLabel("渐变过渡"), transitionTex, transition);

            EditorGUILayout.EndVertical();
        }

        if (EditorGUI.EndChangeCheck())
        {
            if (USE_TRANSITION)
                _targetMat.EnableKeyword("USE_TRANSITION");
            else
                _targetMat.DisableKeyword("USE_TRANSITION");
        }
    }
    
}