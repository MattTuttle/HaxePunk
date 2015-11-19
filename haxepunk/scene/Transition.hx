package haxepunk.scene;

import haxepunk.graphics.*;
import haxepunk.math.Rectangle;
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

    private function initTextures(renderer:Renderer)
    {
        viewport = new Rectangle(0, 0, renderer.window.width, renderer.window.height);
        var width = Std.int(viewport.width);
        var height = Std.int(viewport.height);
        var scene1 = Texture.fromSize(width, height);
        var scene2 = Texture.fromSize(width, height);

        material = new Material();
        material.firstPass.insertTexture(scene1);
        material.firstPass.insertTexture(scene2);
        material.firstPass.shader = new Shader(material.firstPass.shader.vertex, Assets.getText("hxp/shaders/cross.frag"));
    }

    public function draw(renderer:Renderer)
    {
        if (material == null) initTextures(renderer);

        // draw old scene
        renderer.setRenderTarget(scene1);
        renderer.setViewport(viewport);
        oldScene.draw(renderer);

        // draw new scene
        renderer.setRenderTarget(scene2);
        renderer.setViewport(viewport);
        newScene.draw(renderer);

        renderer.setRenderTarget(null);
        renderer.setViewport(oldScene.camera.viewport);
        renderer.clear(renderer.window.backgroundColor);

        var camera = oldScene.camera;
        spriteBatch.begin(renderer, camera.transform);
        spriteBatch.draw(material, 0, 0, camera.width, camera.height,
            0, 0, camera.width, camera.height, false, true);
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
        timeElapsed += Time.elapsed;
        if (timeElapsed >= transitionTime)
        {
            finishTransition.emit();
        }
    }

    private var scene1:Texture;
    private var scene2:Texture;
    private var timeElapsed:Float = 0;
    private var spriteBatch:SpriteBatch;
    private var viewport:Rectangle;
    private var material:Material;

}
