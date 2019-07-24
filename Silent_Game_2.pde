import processing.sound.*;
SoundFile file;

import java.util.*;

ArrayList<Laser> lasers = new ArrayList<Laser>();

ArrayList<Mirror> mirrors = new ArrayList<Mirror>();

ArrayList<Block> blocks = new ArrayList<Block>();

ArrayList<Target> targets = new ArrayList<Target>();

float startX = width*0.9;
float startY = height*0.1;

PImage startscreen;
PFont title;
int gameScreen = 0;
int stage;
int player;

int oldMouseX;
int oldMouseY;

float size = width*0.4;

boolean init;

void setup() {
	// fullScreen();
	size(1024, 768);

	file = new SoundFile(this, "mobamba.mp3");
	file.play();

	player = 1;
}

void draw() {
	if (gameScreen == 0) {
		initScreen();
	} else {
		runGame();
	}
}

void runGame() {
	background(0);
	fill(0);
	stroke(255);
	rect(width*0.01, width*0.01, width*0.2, height*0.8);
	fill(0, 255, 0);
	stroke(0, 255, 0);
	rect(width*0.95, height*0.90, height*0.03, height*0.03);
	drawBlocks();
	drawTargets();
	for (int i = 0; i < targets.size(); i++) {
		targets.get(i).hit = false;
	}
	drawMirrors();
	drawLasers();
	moveObjects();
	textAlign(CENTER);
	textSize(width*0.01);
	if (player == 1) {
		text("Place obstacle blocks with 'b', mirrors with 'm'"
			+ ", lasers with 'l', and targets with 't'", width*0.5, height*0.98);
	} else {
		text("Place lasers with 'l'", width*0.5, height*0.98);
	}
	textAlign(LEFT);
	textSize(width*0.03);
	text("Player " + player, width*0.01, height*0.98);
	oldMouseX = mouseX;
	oldMouseY = mouseY;
}

void drawBlocks() {
	for (int i = 0; i < blocks.size(); i++) {
		fill(130, 130, 130);
		stroke(130, 130, 130);
		if (blocks.get(i).held) {
			stroke(255, 255, 255);
		}
		rect(blocks.get(i).x, blocks.get(i).y, blocks.get(i).width,
			blocks.get(i).height);
	}
}

void drawTargets() {
	for (int i = 0; i < targets.size(); i++) {
		stroke(255, 255, 255);
		fill(255, 255, 255);
		if (targets.get(i).hit) {
			stroke(255, 0, 0);
			fill(255, 0, 0);
		}
		ellipse(targets.get(i).x, targets.get(i).y, targets.get(i).width,
			targets.get(i).height);
		stroke(255, 0, 0);
		fill(255, 0, 0);
		ellipse(targets.get(i).x, targets.get(i).y, targets.get(i).width/2,
			targets.get(i).height/2);
	}
}

void drawMirrors() {
	stroke(255);
	fill(255);
	for (int i = 0; i < mirrors.size(); i++) {
		if (mirrors.get(i).held) {
			stroke(255, 0, 0);
		}
		rect(mirrors.get(i).x, mirrors.get(i).y, mirrors.get(i).width,
			mirrors.get(i).height);
		stroke(255);
	}
}

void drawLasers() {
	stroke(169, 169, 169);
	fill(169, 169, 169);
	for (int i = 0; i < lasers.size(); i++) {
		if (lasers.get(i).held) {
			fill(255);
		}
		if ((lasers.get(i).x < width*0.21) && (lasers.get(i).y < height*0.81)
			&& (lasers.get(i).x > width*0.01) && (lasers.get(i).y > width*0.01)) {

		ellipse(lasers.get(i).x, lasers.get(i).y, lasers.get(i).width,
			lasers.get(i).height);
		float x = lasers.get(i).x;
		float y = lasers.get(i).y;
		stroke(255, 0, 0);
		drawLine(x, y, lasers.get(i).angle * (PI/180));
		}
		fill(169, 169, 169);
	}
}

void drawLine(float x, float y, float angle) {
	float x2 = x;
	float y2 = y;
	boolean collision = false;
	while (!collision && (x2 < width-1) && (y2 < height-1)
		&& (x2 > 0) && (y2 > 0)) {

		x2 += cos(angle);
		y2 -= sin(angle);
		for (int i = 0; i < blocks.size(); i++) {
			if ((x2 > blocks.get(i).x)
				&& (x2 < (blocks.get(i).x + blocks.get(i).width)
				&& (y2 > blocks.get(i).y)
				&& (y2 < (blocks.get(i).y + blocks.get(i).height)))) {

				line(x, y, x2, y2);
				return;
			}
		}
		for (int i = 0; i < targets.size(); i++) {
			if ((x2 > (targets.get(i).x-targets.get(i).width/2))
				&& (y2 > (targets.get(i).y-targets.get(i).height/2))
				&& (x2 < (targets.get(i).x + targets.get(i).width/2))
				&& (y2 < (targets.get(i).y + targets.get(i).height/2))) {

				targets.get(i).hit = true;
			}
		}
		for (int i = 0; i < mirrors.size(); i++) {
			if ((x2 > mirrors.get(i).x)
				&& (x2 < (mirrors.get(i).x + mirrors.get(i).width)
				&& (y2 > mirrors.get(i).y)
				&& (y2 < (mirrors.get(i).y + mirrors.get(i).height)))) {

				collision = true;
				float newAngle = findAngle(x2-3*cos(angle),
					y2+3*sin(angle), (angle/PI)*180, mirrors.get(i));
				if ((newAngle % 90) != 0) {
					drawLine(x2, y2, newAngle);
				}
			}
		}
	}
	line(x, y, x2, y2);
}

float findAngle(float x, float y, float angle, Mirror mirror) {
	angle = angle % 360;
	// println("incoming angle: " + angle);
	println(mirror.x);
	println(x);
	float newAngle = 0;
	if ((x <= mirror.x+1) && (y >= mirror.y-1)
		&& (y <= (mirror.y + mirror.height)+1)) {
		println("LEFT");

		if ((angle % 90 != angle)) {
			newAngle = angle - (2 * (angle % 90));
		} else {
			newAngle = angle + (2 * (90-angle));
		}

	} else if ((y <= mirror.y+1) && (x >= mirror.x-1)
		&& (x <= (mirror.x + mirror.width)+1)) {
		println("ABOVE");

		if ((angle % 270 != angle)) {
			newAngle = angle - (2 * (angle % 360));
		} else {
			newAngle = angle - (2 * (angle % 270));
		}

	} else if ((y >= (mirror.y + mirror.height)-1) && (x >= mirror.x-1)
		&& (x <= (mirror.x + mirror.width)+1)) {
		println("BELOW");

		if ((angle % 90) != angle) {
			newAngle = angle - (2 * (angle % 360));
		} else {
			newAngle = angle - (2 * (angle % 90));
		}

	} else if ((x >= (mirror.x + mirror.width)-1) && (y >= mirror.y-1)
		&& (y <= (mirror.y + mirror.height)+1)) {
		println("RIGHT");

		if ((angle % 270 != angle)) {
			newAngle = angle + (2 * (angle % 270));
		} else {
			newAngle = angle + (2 * (270-angle));
		}
	}
	newAngle = newAngle % 360;
	// println("outgoing angle: " + newAngle);
	return newAngle * PI / 180;
}

void mouseClicked() {
	if (player == 1) {
		for (int i = 0; i < blocks.size(); i++) {
			if ((mouseX > blocks.get(i).x) && (mouseY > blocks.get(i).y)
				&& (mouseX < (blocks.get(i).x + blocks.get(i).width))
				&& (mouseY < (blocks.get(i).y + blocks.get(i).height))) {

				blocks.get(i).held = !blocks.get(i).held;
			}
		}
		for (int i = 0; i < targets.size(); i++) {
			if ((mouseX > (targets.get(i).x-targets.get(i).width/2))
				&& (mouseY > (targets.get(i).y-targets.get(i).height/2))
				&& (mouseX < (targets.get(i).x + targets.get(i).width/2))
				&& (mouseY < (targets.get(i).y + targets.get(i).height/2))) {

				targets.get(i).held = !targets.get(i).held;
			}
		}
		for (int i = 0; i < mirrors.size(); i++) {
			if ((mouseX > mirrors.get(i).x) && (mouseY > mirrors.get(i).y)
				&& (mouseX < (mirrors.get(i).x + mirrors.get(i).width))
				&& (mouseY < (mirrors.get(i).y + mirrors.get(i).height))) {

				mirrors.get(i).held = !mirrors.get(i).held;
			}
		}
		for (int i = 0; i < lasers.size(); i++) {
			if ((mouseX > (lasers.get(i).x-lasers.get(i).width/2))
				&& (mouseY > (lasers.get(i).y-lasers.get(i).height/2))
				&& (mouseX < (lasers.get(i).x + lasers.get(i).width/2))
				&& (mouseY < (lasers.get(i).y + lasers.get(i).height/2))) {

				lasers.get(i).held = !lasers.get(i).held;
			}
		}
	} else if (player == 2) {
		for (int i = 0; i < lasers.size(); i++) {
			if ((mouseX > (lasers.get(i).x-lasers.get(i).width/2))
				&& (mouseY > (lasers.get(i).y-lasers.get(i).height/2))
				&& (mouseX < (lasers.get(i).x + lasers.get(i).width/2))
				&& (mouseY < (lasers.get(i).y + lasers.get(i).height/2))) {

				lasers.get(i).held = !lasers.get(i).held;
			}
		}
	}
	if ((mouseX > width*0.95) && (mouseY > height*0.90)
		&& (mouseX < width*0.98) && (mouseY < height*0.93)) {

		if (player == 1) {
			player++;
			for (int i = 0; i < lasers.size(); i++) {
				lasers.removeAll(lasers);
			}
		}

	}
}

void moveObjects() {
	if (player == 1) {
		for (int i = 0; i < blocks.size(); i++) {
			if (blocks.get(i).held) {
				blocks.get(i).x += mouseX - oldMouseX;
				blocks.get(i).y += mouseY - oldMouseY;
			}
		}
		for (int i = 0; i < targets.size(); i++) {
			if (targets.get(i).held) {
				targets.get(i).x += mouseX - oldMouseX;
				targets.get(i).y += mouseY - oldMouseY;
			}
		}
		for (int i = 0; i < lasers.size(); i++) {
			if (lasers.get(i).held) {
				lasers.get(i).x += mouseX - oldMouseX;
				lasers.get(i).y += mouseY - oldMouseY;
			}
		}
		for (int i = 0; i < mirrors.size(); i++) {
			if (mirrors.get(i).held) {
				mirrors.get(i).x += mouseX - oldMouseX;
				mirrors.get(i).y += mouseY - oldMouseY;
			}
		}
	} else if (player == 2) {
		for (int i = 0; i < lasers.size(); i++) {
			if (lasers.get(i).held) {
				lasers.get(i).x += mouseX - oldMouseX;
				lasers.get(i).y += mouseY - oldMouseY;
			}
		}
	}
}

void keyPressed() {
	if ((player == 1) && !init) {
		if (key == 'b') {
			if (blocks.size() == 0) {
				blocks.add(new Block(mouseX-width*0.005, mouseY-height*0.075,
					width*0.01, height*0.15));
			} else if (!blocks.get(blocks.size()-1).held) {
				blocks.add(new Block(mouseX-width*0.005, mouseY-height*0.075,
					width*0.01, height*0.15));
			}
		} else if (key == 't') {
			if (targets.size() == 0) {
				targets.add(new Target(mouseX, mouseY, size, size));
			} else if (!targets.get(targets.size()-1).held) {
				targets.add(new Target(mouseX, mouseY, size, size));
			}
		} else if (key == 'm') {
			if (mirrors.size() == 0) {
				mirrors.add(new Mirror(mouseX-size/2, mouseY-size/2,
					size, size));
			} else if (!mirrors.get(mirrors.size()-1).held) {
				mirrors.add(new Mirror(mouseX-size/2, mouseY-size/2,
					size, size));
			}
		} else if (key == 'l') {
			if (lasers.size() == 0) {
				lasers.add(new Laser(mouseX, mouseY, size, size, -45));
			} else if (!lasers.get(lasers.size()-1).held) {
				lasers.add(new Laser(mouseX, mouseY, size, size, -45));
			}
		} else if (key == 'z') {
			for (int i = 0; i < blocks.size(); i++) {
				if (blocks.get(i).held) {
					float temp = blocks.get(i).width;
					blocks.get(i).width = blocks.get(i).height;
					blocks.get(i).height = temp;
					blocks.get(i).x = mouseX-blocks.get(i).width/2;
					blocks.get(i).y = mouseY-blocks.get(i).height/2;
				}
			}
		}
	} else if ((player == 2) && !init) {
		if (key == 'l') {
			if (lasers.size() == 0) {
				lasers.add(new Laser(mouseX, mouseY, size, size, -45));
			} else if (!lasers.get(lasers.size()-1).held) {
				lasers.add(new Laser(mouseX, mouseY, size, size, -45));
			}
		}
	}
	if ((key == 'd') && !init) {
		if (player == 1) {
			for (int i = 0; i < blocks.size(); i++) {
				if (blocks.get(i).held) {
					blocks.remove(i);
				}
			}
			for (int i = 0; i < targets.size(); i++) {
				if (targets.get(i).held) {
					targets.remove(i);
				}
			}
			for (int i = 0; i < mirrors.size(); i++) {
				if (mirrors.get(i).held) {
					mirrors.remove(i);
				}
			}
		} else if (player == 2) {
			for (int i = 0; i < lasers.size(); i++) {
				if (lasers.get(i).held) {
					lasers.remove(i);
				}
			}
		}
	}
	if ((key == CODED) && !init) {
		if (keyCode == LEFT) {
			for (int i = 0; i < lasers.size(); i++) {
				if (lasers.get(i).held) {
					lasers.get(i).angle++;
				}
			}
		} else if (keyCode == RIGHT) {
			for (int i = 0; i < lasers.size(); i++) {
				if (lasers.get(i).held) {
					lasers.get(i).angle--;
				}
			}
		}
	}
}

void initScreen() {
	init = true;
	startscreen = loadImage("laser.jpg");
	image(startscreen, 0, 0, width, height);
	title = createFont("font", 1000, true);
	textAlign(CENTER);
	textSize(width*0.05);
	text("Laser Beam Builder", width*0.3, height*0.3);
	textSize(width*0.04);
	text("Press any key to start game", width*0.3, height*0.38);
	if (keyPressed && (key != 'g')) {
		gameScreen++;
		init = false;
	}
}