using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
public class ExplosionSphereShaderGUI :ShaderGUI 
{
    private MaterialEditor     materialEditor; //当前材质面板
    private MaterialProperty[] properties;     //当前shader的properties
    
    private Material           targetMat;      //绘制对象材质球
    private string[]           keyWords;       //当前shader keywords
    public override void OnGUI (MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //Init
        this.materialEditor = materialEditor;
        this.properties     = properties;
        this.targetMat      = materialEditor.target as Material;
        this.keyWords       = this.targetMat.shaderKeywords;
        ShowGUI();
    }

    private void ShowGUI()
    {
        base.OnGUI (materialEditor, properties);
        EditorGUI.BeginChangeCheck();
        ShowTransition();
        ShowFresnel();
    }
    
    //抄这个https://blog.csdn.net/enk_2/article/details/109236874

    private void ShowFresnel()
    {
        bool USE_FRESNEL = Array.IndexOf(this.keyWords, "USE_FRESNEL") != -1;
        USE_FRESNEL = EditorGUILayout.Toggle("USE_FRESNEL", USE_FRESNEL);
        if (EditorGUI.EndChangeCheck())
        {
            if (USE_FRESNEL)
                targetMat.EnableKeyword("USE_FRESNEL");
            else
                targetMat.DisableKeyword("USE_FRESNEL");
        }
    }

    private void ShowTransition()
    {
        bool USE_TRANSITION = Array.IndexOf(this.keyWords, "USE_TRANSITION") != -1;
        USE_TRANSITION = EditorGUILayout.Toggle("USE_FRESNEL", USE_TRANSITION);
        if (EditorGUI.EndChangeCheck())
        {
            if (USE_TRANSITION)
                targetMat.EnableKeyword("USE_TRANSITION");
            else
                targetMat.DisableKeyword("USE_TRANSITION");
        }
    }

    private void SetFresnelPanel()
    {
        
    }
}
