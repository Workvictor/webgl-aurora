import { shaders } from 'src/shaders';
import './index.css'

function resizeCanvas(canvas: HTMLCanvasElement) {
	if (canvas.width !== canvas.offsetWidth) {
		canvas.width = canvas.offsetWidth;
	}
	if (canvas.height !== canvas.offsetHeight) {
		canvas.height = canvas.offsetHeight;
	}
}

const canvas = document.createElement('canvas');
const gl = canvas.getContext('webgl')!;

document.body.appendChild(canvas);

const shaderFetchList = [shaders.vertexShaderSource, shaders.fragnemtShaderSource].map((url) =>
	fetch(url).then((r) => r.text())
);

Promise.all(shaderFetchList).then(([vertexShaderSource, fragnemtShaderSource]) => {
	const program = gl.createProgram()!;

	const vertexShader = gl.createShader(gl.VERTEX_SHADER)!;
	gl.shaderSource(vertexShader, vertexShaderSource);
	gl.compileShader(vertexShader);
	gl.attachShader(program, vertexShader);

	const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)!;
	gl.shaderSource(fragmentShader, fragnemtShaderSource);
	gl.compileShader(fragmentShader);

	gl.attachShader(program, fragmentShader);
	gl.linkProgram(program);
	const positionAttributeLocation = gl.getAttribLocation(program, 'position');
	const resolutionUL = gl.getUniformLocation(program, 'iResolution');
	const timeUL = gl.getUniformLocation(program, 'iTime');
	const positionBuffer = gl.createBuffer();

	gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
	gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]), gl.STATIC_DRAW);

	let timePrev = 0;
	function render(timeNow: number) {
		const elapsedTime = timeNow - timePrev;
		timePrev = timeNow;

		resizeCanvas(canvas);
		gl.viewport(0, 0, canvas.width, canvas.height);
		gl.useProgram(program);
		gl.enableVertexAttribArray(positionAttributeLocation);
		gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
		gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);

		gl.uniform2f(resolutionUL, canvas.width, canvas.height);
		gl.uniform1f(timeUL, (timeNow + elapsedTime) / 1000);

		gl.drawArrays(gl.TRIANGLES, 0, 6);

		requestAnimationFrame(render);
	}

	requestAnimationFrame(render);
});
