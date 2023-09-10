precision highp float;
uniform vec2 iResolution;
uniform float iTime;

mat2 mm2(in float a) {
	float c = cos(a), s = sin(a);
	return mat2(c, s, -s, c);
}

mat2 m2 = mat2(0.95534, 0.29552, -0.29552, 0.95534);

float tri(in float x) {
	return clamp(abs(fract(x) - .5), 0.01, 0.49);
}

vec2 tri2(in vec2 p) {
	return vec2(tri(p.x) + tri(p.y), tri(p.y + tri(p.x)));
}

float clamped_noise(in vec2 p, float spd) {
	float z = 1.8;
	float z2 = 2.5;
	float rz = 0.;
	p *= mm2(p.x * 0.06);
	vec2 bp = p;
	for(float i = 0.; i < 5.; i++) {
		vec2 dg = tri2(bp * 1.85) * .75;
		dg *= mm2(iTime * spd);
		p -= dg / z2;

		bp *= 1.3;
		z2 *= .45;
		z *= .42;
		p *= 1.21 + (rz - 1.0) * .02;

		rz += tri(p.x + tri(p.y)) * z;
		p *= -m2;
	}
	return clamp(1. / pow(rz * 29., 1.3), 0., .55);
}

float hash_fract(in vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

vec4 make_aurora(vec3 ro, vec3 rd) {
	vec4 col = vec4(0);
	vec4 avgCol = vec4(0);

	for(float i = 0.; i < 50.; i++) {
		float of = 0.003 * hash_fract(gl_FragCoord.xy) * smoothstep(0., 15., i);
		float pt = ((.8 + pow(i, 1.4) * .002) - ro.y) / (rd.y * 2. + 0.4);
		pt -= of;
		vec3 bpos = ro + pt * rd;
		vec2 p = bpos.zx;
		float rzt = clamped_noise(p, 0.07);
		vec4 col2 = vec4(0, 0, 0, rzt);
		col2.rgb = (sin(1. - vec3(2.15, -.5, 1.2) + i * 0.043) * 0.5 + 0.5) * rzt;
		avgCol = mix(avgCol, col2, .5);
		col += avgCol * exp2(-i * 0.065 - 2.5) * smoothstep(0., 5., i);

	}

	col *= (clamp(rd.y * 15. + .4, 0., 1.));

	return col * 1.8;
}

const float cHashM = 43758.54;

vec4 Hashv4v3(vec3 p) {
	vec3 cHashVA3 = vec3(37., 39., 41.);
	vec2 e = vec2(1., 0.);
	return fract(sin(vec4(dot(p + e.yyy, cHashVA3), dot(p + e.xyy, cHashVA3), dot(p + e.yxy, cHashVA3), dot(p + e.xxy, cHashVA3))) * cHashM);
}

float Noisefv3(vec3 p) {
	vec4 t;
	vec3 ip, fp;
	ip = floor(p);
	fp = fract(p);
	fp *= fp * (3. - 2. * fp);
	t = mix(Hashv4v3(ip), Hashv4v3(ip + vec3(0., 0., 1.)), fp.z);
	return mix(mix(t.x, t.y, fp.x), mix(t.z, t.w, fp.x), fp.y);
}

vec3 stars_color(vec3 rd) {
	vec3 rds;
	rds = floor(2000. * rd);
	rds = 0.000315 * rds + 0.1 * Noisefv3(0.0005 * rds.yzx);
	for(int j = 0; j < 19; j++) rds = abs(rds) / dot(rds, rds) - 0.9;
	return 0.25 * vec3(0.2941, 0.2902, 0.0196) * min(1., 0.5e-3 * pow(min(6., length(rds)), 4.));
}

vec3 get_color(in vec3 rd) {
	float sd = dot(normalize(vec3(-0.5, -0.6, 0.9)), rd) * 0.5 + 0.5;
	sd = pow(sd, 5.);
	vec3 color = mix(vec3(0.05, 0.1, 0.2), vec3(0.1, 0.05, 0.2), sd);
	return color * .63;
}

void main() {
	vec2 q = gl_FragCoord.xy / iResolution.xy;
	vec2 p = q - 0.4;
	p.x *= iResolution.x / iResolution.y;

	vec3 ro = vec3(0, 0, -6.567);
	vec3 rd = normalize(vec3(p, 1.1));
	vec2 mo = vec3(0, 0, 0).xy / iResolution.xy - .5;
	mo = (mo == vec2(-.5)) ? mo = vec2(-0.1, 0.1) : mo;
	mo.x *= iResolution.x / iResolution.y;
	rd.yz *= mm2(mo.y);

	vec3 color = vec3(0.);
	vec3 brd = rd;
	float fade = smoothstep(0., 0.01, abs(brd.y)) * 0.1 + 0.9;

	color = get_color(rd) * fade;

	if(rd.y > 0.) {
		vec4 aurora = smoothstep(0., 1.5, make_aurora(ro, rd)) * fade;
		color += stars_color(rd) * fade * 0.9;
		color = color * (1. - aurora.a) + aurora.rgb;
	} else {
		rd.y = abs(rd.y);
		color = get_color(rd) * fade * 0.6;
		vec4 aurora = smoothstep(0.0, 2.5, make_aurora(ro, rd));
		color += stars_color(rd) * fade * 0.2;
		color = color * (1. - aurora.a) + aurora.rgb;
		vec3 pos = ro + ((0.5 - ro.y) / rd.y) * rd;
		float nz2 = clamped_noise(pos.xz * vec2(.5, .7), 0.);
		color += mix(vec3(0.2, 0.25, 0.5) * 0.08, vec3(0.3, 0.3, 0.5) * 0.7, nz2 * 0.4);
	}

	gl_FragColor = vec4(color, 1.);
}
