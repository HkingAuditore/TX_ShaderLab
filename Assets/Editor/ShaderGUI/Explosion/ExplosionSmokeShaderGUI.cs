using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ExplosionSmokeShaderGUI  : ExplosionShaderGUI
{
    private bool _isFresnelShown = true;
    
    protected override void ShowGUI()
    {
        ShowMain();
        GUILayout.Space(15);
        ShowFresnel();
        GUILayout.Space(15);
        ShowLighting();
        GUILayout.Space(15);
        ShowRenderingSetting();

    }

    private void ShowMain()
    {
        GUILayout.Label("基本", EditorStyles.boldLabel);
        var rampTex = FindThisProperty("_RampTex");
        var rampPower = FindThisProperty("_RampPower");
        var rampOffset = FindThisProperty("_RampOffset");
        var rampSize = FindThisProperty("_RampSize");
        var burnTex = FindThisProperty("_BurnTex");
        var cutoff = FindThisProperty("_Cutoff");
        var normal = FindThisProperty("_SmokeNormal");
        var normalIntensity = FindThisProperty("_NormalIntensity");

        MaterialEditor.TexturePropertySingleLine(GetLabel("颜色采样"), rampTex);
        EditorGUI.indentLevel++;
        MaterialEditor.ShaderProperty(rampPower,GetLabel("强度"));
        MaterialEditor.ShaderProperty(rampOffset,GetLabel("采样偏移"));
        MaterialEditor.ShaderProperty(rampSize,GetLabel("高光系数"));
        EditorGUI.indentLevel--;
        MaterialEditor.TexturePropertySingleLine(GetLabel("法线"), normal,normalIntensity);
        MaterialEditor.TexturePropertySingleLine(GetLabel("溶解"), burnTex, cutoff);

    }

    
    private void ShowFresnel()
    {
        
        var origFontStyle = EditorStyles.label.fontStyle;
        EditorStyles.label.fontStyle = FontStyle.Bold;
        _isFresnelShown = EditorGUILayout.BeginFoldoutHeaderGroup(_isFresnelShown, "中心补光");
        EditorStyles.label.fontStyle = origFontStyle;
        if (_isFresnelShown)
        {
            EditorGUILayout.BeginVertical("box");

            var fresnelThreshold = FindThisProperty("_FresnelThreshold");
            var fresnelIntensity = FindThisProperty("_FresnelIntensity");

            MaterialEditor.ShaderProperty(fresnelThreshold, GetLabel("补光范围"));
            MaterialEditor.ShaderProperty(fresnelIntensity, GetLabel("补光强度"));

            EditorGUILayout.EndVertical();
        }
        EditorGUILayout.EndFoldoutHeaderGroup();

    }

    private void ShowLighting()
    {
        EditorGUI.BeginChangeCheck();
        var USE_LIGHTING = Array.IndexOf(KeyWords, "USE_LIGHTING") != -1;
        var origFontStyle = EditorStyles.label.fontStyle;
        EditorStyles.label.fontStyle = FontStyle.Bold;
        USE_LIGHTING = EditorGUILayout.Toggle("光照", USE_LIGHTING, EditorStyles.toggle);
        EditorStyles.label.fontStyle = origFontStyle;

        if (USE_LIGHTING)
        {
            EditorGUILayout.BeginVertical("box");

            var lightIntensity = FindThisProperty("_LightIntensity");

            MaterialEditor.ShaderProperty(lightIntensity, GetLabel("光照强度"));

            EditorGUILayout.EndVertical();
        }


        if (EditorGUI.EndChangeCheck())
        {
            if (USE_LIGHTING)
                TargetMat.EnableKeyword("USE_LIGHTING");
            else
                TargetMat.DisableKeyword("USE_LIGHTING");
        }

    }
}
