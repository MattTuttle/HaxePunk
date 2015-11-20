package haxepunk.scene;

import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.renderers.Renderer;
import haxepunk.utils.Time;
import hxsignal.Signal;

class Transition
{

    public var oldScene:Scene;
    public var newScene:Scene;
    public var transitionTime(default, null):Float;
    public var finishTransition = new Signal<Void->Void>();

    public function new(transitionTime:Float=0)
    {
        this.transitionTime = transitionTime;
        spriteBatch = new SpriteBatch();
    }

    private function initTextures(window:Window)
    {
        var camera = oldScene.camera;
        camera.scaleMode = NoScale; // TODO: make this non-destructive
        camera.update(window);
        viewport = camera.viewport;
        var width = Std.int(viewport.width * window.pixelScale);
        var height = Std.int(viewport.height * window.pixelScale);
        scene1 = Texture.fromSize(width, height, 24);
        scene2 = Texture.fromSize(width, height, 24);

        material = new Material();
        var pass = material.firstPass;
        pass.insertTexture(scene1, 0);
        pass.insertTexture(scene2, 1);
#if flash
        #error "need shader"
#else
        pass.shader = new Shader(pass.shader.vertex, Assets.getText("hxp/shaders/cross.frag"));
#end
    }

    public function draw(renderer:Renderer)
    {
        var window = renderer.window;
        if (material == null) initTextures(window);

        // set to texture viewport
        renderer.setViewport(viewport);

        // draw old scene to texture
        renderer.setRenderTarget(scene1);
        oldScene.draw(renderer);

        // draw new scene to texture
        renderer.setRenderTarget(scene2);
        newScene.draw(renderer);

        // draw mix of two scenes to screen with shader
        renderer.setRenderTarget(null);
        renderer.clear(renderer.window.backgroundColor);
        renderer.setViewport(camera.viewport);

        spriteBatch.begin(renderer, camera.transform);
        spriteBatch.draw(material, 0, 0, window.width, window.height,
            0, 0, scene1.width, scene1.height, false, true);
        // set uniforms
        renderer.bindShader(material.firstPass.shader);
        renderer.setFloat("uProgress", timeElapsed / transitionTime);
        renderer.setFloat("uWidth", camera.width);
        renderer.setFloat("uHeight", camera.height);
        spriteBatch.end();
    }

    public function update(window:Window)
    {
        oldScene.update(window);
        newScene.update(window);
        camera.update(window);
        timeElapsed += Time.elapsed;
        if (timeElapsed >= transitionTime)
        {
            finishTransition.emit();
        }
    }

    private var camera = new Camera();
    private var scene1:Texture;
    private var scene2:Texture;
    private var timeElapsed:Float = 0;
    private var spriteBatch:SpriteBatch;
    private var viewport:Rectangle;
    private var material:Material;

}
