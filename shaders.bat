@ECHO OFF
sokol-shdc -i src\shaders\shaders.glsl -o src\shaders\shaders.glsl.h -l hlsl5
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

sokol-shdc -i modules\xvg\xvg_shaders.glsl -o src\shaders\xvg_shaders.glsl.h -l hlsl5
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
