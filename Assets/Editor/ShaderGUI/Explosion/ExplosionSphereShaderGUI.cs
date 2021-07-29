using System;
using UnityEditor;
using UnityEngine;

internal enum RotationType
{
    UseOffset,
    UseSpeed
}

public class ExplosionSphereShaderGUI : ExplosionShaderGUI
{
    private Vector2 _uvJump;
    protected override void ShowGUI()
    {
        ShowMain();
        GUILayout.Space(15);
        ShowTransition();
        GUILayout.Space(15);
        ShowFresnel();
        GUILayout.Space(15);
        ShowDistort();
        GUILayout.Space(15);
        ShowRenderingSetting();
    }



    #region GUI显示

    private void ShowMain()
    {
        EditorGUI.BeginChangeCheck();

        GUILayout.Label("基本", EditorStyles.boldLabel);
        var tex0 = FindThisProperty("_Tex0");
        var tex0Ramp = FindThisProperty("_Tex0Ramp");
        var color = FindThisProperty("_Color0");
        var burnTex = FindThisProperty("_BurnTex");
        var cutoff = FindThisProperty("_Cutoff");

        MaterialEditor.TexturePropertySingleLine(GetLabel("主贴图"), tex0);
        MaterialEditor.TexturePropertySingleLine(GetLabel("颜色采样"), tex0Ramp, color);
        MaterialEditor.TexturePropertySingleLine(GetLabel("溶解"), burnTex, cutoff);


        GUILayout.Space(10);
        GUILayout.Label("UV滚动", EditorStyles.boldLabel);
        var USE_OFFSET = TargetMat.IsKeywordEnabled("USE_OFFSET");
        var rotationType = USE_OFFSET ? RotationType.UseOffset : RotationType.UseSpeed;
        rotationType = (RotationType) EditorGUILayout.Popup("UV滚动操作单位", (int) rotationType, new[] {"UV滚动量", "UV滚动速度"});
        switch (rotationType)
        {
            case RotationType.UseOffset:
                var rotation = FindThisProperty("_Rotation");
                MaterialEditor.ShaderProperty(rotation, GetLabel("UV滚动量"));
                break;
            case RotationType.UseSpeed:
                var rotationSpeed = FindThisProperty("_RotateSpeed");
                MaterialEditor.ShaderProperty(rotationSpeed, GetLabel("UV滚动速度"));

                break;
            default:
                throw new ArgumentOutOfRangeException();
        }

        if (EditorGUI.EndChangeCheck())
        {
            MaterialEditor.RegisterPropertyChangeUndo("UV滚动操作单位");
            switch (rotationType)
            {
                case RotationType.UseOffset:
                    TargetMat.EnableKeyword("USE_OFFSET");
                    break;
                case RotationType.UseSpeed:
                    TargetMat.DisableKeyword("USE_OFFSET");
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }
    }

    private void ShowFresnel()
    {
        EditorGUI.BeginChangeCheck();
        var USE_FRESNEL = Array.IndexOf(KeyWords, "USE_FRESNEL") != -1;
        var origFontStyle = EditorStyles.label.fontStyle;
        EditorStyles.label.fontStyle = FontStyle.Bold;
        USE_FRESNEL = EditorGUILayout.Toggle("边缘光", USE_FRESNEL, EditorStyles.toggle);
        EditorStyles.label.fontStyle = origFontStyle;

        if (USE_FRESNEL)
        {
            EditorGUILayout.BeginVertical("box");

            var fresnelIntensity = FindThisProperty("_FresnelIntensity");
            var fresnelSize = FindThisProperty("_FresnelSize");
            var fresnelColor = FindThisProperty("_FresnelColor");

            MaterialEditor.ShaderProperty(fresnelColor, GetLabel("边缘光颜色"));
            MaterialEditor.ShaderProperty(fresnelIntensity, GetLabel("边缘光硬度"));
            MaterialEditor.ShaderProperty(fresnelSize, GetLabel("边缘光范围"));

            EditorGUILayout.EndVertical();
        }


        if (EditorGUI.EndChangeCheck())
        {
            if (USE_FRESNEL)
                TargetMat.EnableKeyword("USE_FRESNEL");
            else
                TargetMat.DisableKeyword("USE_FRESNEL");
        }
    }

    private void ShowTransition()
    {
        EditorGUI.BeginChangeCheck();
        var USE_TRANSITION = Array.IndexOf(KeyWords, "USE_TRANSITION") != -1;
        var origFontStyle = EditorStyles.label.fontStyle;
        EditorStyles.label.fontStyle = FontStyle.Bold;
        USE_TRANSITION = EditorGUILayout.Toggle("渐变", USE_TRANSITION, EditorStyles.toggle);
        EditorStyles.label.fontStyle = origFontStyle;

        if (USE_TRANSITION)
        {
            TargetMat.EnableKeyword("USE_TRANSITION");
            EditorGUILayout.BeginVertical("box");

            var tex1 = FindThisProperty("_Tex1");
            var tex1Ramp = FindThisProperty("_Tex1Ramp");
            var transitionTex = FindThisProperty("_TransitionTex");
            var color = FindThisProperty("_Color1");
            var transition = FindThisProperty("_Transition");

            MaterialEditor.TexturePropertySingleLine(GetLabel("渐变目标贴图"), tex1);
            MaterialEditor.TexturePropertySingleLine(GetLabel("渐变颜色采样"), tex1Ramp, color);
            MaterialEditor.TexturePropertySingleLine(GetLabel("渐变过渡"), transitionTex, transition);

            EditorGUILayout.EndVertical();
        }

        if (EditorGUI.EndChangeCheck())
        {
            if (USE_TRANSITION)
                TargetMat.EnableKeyword("USE_TRANSITION");
            else
                TargetMat.DisableKeyword("USE_TRANSITION");
        }
    }

    private void ShowDistort()
    {
        EditorGUI.BeginChangeCheck();
        var USE_FLOWMAP = Array.IndexOf(KeyWords, "USE_FLOWMAP") != -1;
        var origFontStyle = EditorStyles.label.fontStyle;
        EditorStyles.label.fontStyle = FontStyle.Bold;
        USE_FLOWMAP = EditorGUILayout.Toggle("扰动", USE_FLOWMAP, EditorStyles.toggle);
        EditorStyles.label.fontStyle = origFontStyle;

        if (USE_FLOWMAP)
        {
            TargetMat.EnableKeyword("USE_FLOWMAP");
            EditorGUILayout.BeginVertical("box");

            var flowMap = FindThisProperty("_FlowMap");
            var uJump = FindThisProperty("_UJump");
            var vJump = FindThisProperty("_UJump");
            var flowIntensity = FindThisProperty("_FlowIntensity");
            var flowTimeScale = FindThisProperty("_FlowTimeScale");


            MaterialEditor.TexturePropertySingleLine(GetLabel("扰动图"), flowMap,flowIntensity);
            EditorGUI.indentLevel++;
            MaterialEditor.TextureScaleOffsetProperty(flowMap);
            EditorGUI.indentLevel--;
            MaterialEditor.ShaderProperty(flowTimeScale,GetLabel("扰动速度"));

            _uvJump = EditorGUILayout.Vector2Field("UV跳跃", new Vector2(TargetMat.GetFloat("_UJump"),TargetMat.GetFloat("_VJump")));

            EditorGUILayout.EndVertical();
        }

        if (EditorGUI.EndChangeCheck())
        {
            if (USE_FLOWMAP)
            {
                TargetMat.EnableKeyword("USE_FLOWMAP");
                TargetMat.SetFloat("_UJump",_uvJump.x);
                TargetMat.SetFloat("_VJump",_uvJump.y);
            }else
            {
                TargetMat.DisableKeyword("USE_FLOWMAP");
            }
            
        }

    }

    #endregion
}