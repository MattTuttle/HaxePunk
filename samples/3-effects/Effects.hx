import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.scene.Scene;

class EffectsScene extends Scene
{
	public function new(window:Window)
	{
		super();
		emitter = new ParticleEmitter("assets/particle.png");
		emitter.acceleration.y = 0.05;
		emitter.randomVelocity.x = 1;
		emitter.velocity.y = -0.3;
		emitter.angularVelocity = 0.01;
		emitter.randomAngularVelocity = 0.1;
		emitter.growth.x = emitter.growth.y = 0.05;
		emitter.centerOrigin();
		addGraphic(emitter, 0, window.width / 2, 25);

		particleCount = new Text("");
		addGraphic(particleCount, 0, 0, 15);
	}

	override public function update(window:Window)
	{
		emitter.emit(5);
		particleCount.text = "Particles " + emitter.count + "\nFPS " + Std.int(window.fps);
		super.update(window);
	}

	private var particleCount:Text;
	private var emitter:ParticleEmitter;
}

class Effects extends Engine
{
	override public function ready(window:Window)
	{
		window.scene = new EffectsScene(window);
	}
}
