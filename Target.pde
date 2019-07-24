class Target {

	float x, y, width, height;
	boolean held, hit;

	Target(float x, float y, float width, float height) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		held = true;
		hit = false;
	}

}