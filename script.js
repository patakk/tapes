
import {noise} from "./noise.js";

let canvas;
let ctx;

let curves = [];
let currentCurve = [];

function main() {
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");

    // set width and height, full screen
    onresize(null);
    setCanvasEvents();

    setupCurves();

    renderCurves();
}

function rand(a, b){
    return a + Math.random()*(b-a);
}

function map(value, min1, max1, min2, max2){
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

function setupCurves(){

    let pos = new Vector(canvas.width/2 + rand(-200, 200), canvas.height/2 + rand(-200, 200));
    let vel = new Vector(rand(-1, 1), rand(-1, 1));
    vel.normalize();

    let curve = [];

    let center = new Vector(canvas.width/2, canvas.height/2);

    let margin = 100;
    let iters = Math.round(rand(3, 10));
    let sumpoints = new Vector(0, 0);
    for(let i = 0; i < iters; i++){
        let cvel = vel.clone();
        cvel.rotate(map(power(rand(0, 1), 3), 0, 1, Math.PI/2, Math.PI*3/2));
        cvel.normalize();
        cvel.multiplyScalar(rand(400, 1400));
        let newPos = new Vector(pos.x + cvel.x, pos.y + cvel.y);
        let tries = 0;
        while(tries++ < 30 && (newPos.x < margin || newPos.x > canvas.width-margin || newPos.y < margin || newPos.y > canvas.height-margin)){
            cvel = vel.clone();
            cvel.rotate(map(power(rand(0, 1), 3), 0, 1, Math.PI/2, Math.PI*3/2));
            cvel.normalize();
            cvel.multiplyScalar(rand(400, 1400));
            newPos = new Vector(pos.x + cvel.x, pos.y + cvel.y);
        }
        vel = cvel.clone();
        pos = newPos;
        curve.push(newPos);
        sumpoints.add(newPos);
    }
    sumpoints.multiplyScalar(1/iters);
    for(let i = 0; i < curve.length; i++){
        curve[i].sub(sumpoints);
        curve[i].add(center);
    }

    curves.push(curve);
}

function hsvToRgb(h, s, v) {
    let r, g, b;
    let i = Math.floor(h * 6);
    let f = h * 6 - i;
    let p = v * (1 - s);
    let q = v * (1 - f*s);
    let t = v * (1 - (1 - f) * s);
    switch(i % 6){
        case 0: r = v, g = t, b = p; break;
        case 1: r = q, g = v, b = p; break;
        case 2: r = p, g = v, b = t; break;
        case 3: r = p, g = q, b = v; break;
        case 4: r = t, g = p, b = v; break;
        case 5: r = v, g = p, b = q; break;
    }
    return [Math.floor(r*255), Math.floor(g*255), Math.floor(b*255)];
}

const SCALE = 1;

function onresize(event){
    // set width and height, full screen
    canvas.width = window.innerWidth*SCALE;
    canvas.height = window.innerHeight*SCALE;
    canvas.style.width = window.innerWidth + "px";
    canvas.style.height = window.innerHeight + "px";
}
    
function renderCurves() {
    ctx.fillStyle = "#dfdfdf";
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    for(let i = 0; i < curves.length; i++){
        renderCurve(i);
    }
}

class Vector{
    constructor(x, y){
        this.x = x;
        this.y = y;
    }

    add(vec){
        this.x += vec.x;
        this.y += vec.y;
    }

    sub(vec){
        this.x -= vec.x;
        this.y -= vec.y;
    }

    normalize(){
        let length = Math.sqrt(this.x*this.x + this.y*this.y);
        this.x /= length;
        this.y /= length;
    }

    rotate(angle){
        let newX = this.x * Math.cos(angle) - this.y * Math.sin(angle);
        let newY = this.x * Math.sin(angle) + this.y * Math.cos(angle);
        this.x = newX;
        this.y = newY;
    }

    clone(){
        return new Vector(this.x, this.y);
    }

    dot(vec){
        return this.x * vec.x + this.y * vec.y;
    }

    multiplyScalar(scalar){
        this.x *= scalar;
        this.y *= scalar;
    }

    length(){
        return Math.sqrt(this.x*this.x + this.y*this.y);
    }

    distance(vec){
        return Math.sqrt(Math.pow(this.x - vec.x, 2) + Math.pow(this.y - vec.y, 2));
    }
    
}

function power(p, g) {
    if (p < 0.5)
        return 0.5 * Math.pow(2*p, g);
    else
        return 1 - 0.5 * Math.pow(2*(1 - p), g);
}

let oklab = {
    // Source:
    // https://www.npmjs.com/package/oklab
    oklabTosRGB: (L, a, b) => {
    const l = (L + a * +0.3963377774 + b * +0.2158037573) ** 3;
    const m = (L + a * -0.1055613458 + b * -0.0638541728) ** 3;
    const s = (L + a * -0.0894841775 + b * -1.2914855480) ** 3;

    return {
        r: l * +4.0767245293 + m * -3.3072168827 + s * +0.2307590544,
        g: l * -1.2681437731 + m * +2.6093323231 + s * -0.3411344290,
        b: l * -0.0041119885 + m * -0.7034763098 + s * +1.7068625689
    };
    },
    sRGBToOklab: (r, g, b) => {
    const l = Math.cbrt(r * +0.4121656120 + g * +0.5362752080 + b * +0.0514575653);
    const m = Math.cbrt(r * +0.2118591070 + g * +0.6807189584 + b * +0.1074065790);
    const s = Math.cbrt(r * +0.0883097947 + g * +0.2818474174 + b * +0.6302613616);

    return {
        L: l * +0.2104542553 + m * +0.7936177850 + s * -0.0040720468,
        a: l * +1.9779984951 + m * -2.4285922050 + s * +0.4505937099,
        b: l * +0.0259040371 + m * +0.7827717662 + s * -0.8086757660
    };
    }
}

function renderCurve(i){
    let curveindex = i;
    let points = curves[i];

    // ctx.fillStyle = "rgb(" + 255*noise(i) + "," + 255*noise(i+1.3) + "," +  255*noise(i+2.8) + ")";
    // for(let i = 0; i < points.length; i++){
    //     ctx.beginPath();
    //     ctx.arc(points[i].x, points[i].y, 5, 0, 2 * Math.PI);
    //     ctx.fill();
    // }
    
    // ctx.strokeStyle = "rgb(" + 255*noise(i) + "," + 255*noise(i+1.3) + "," +  255*noise(i+2.8) + ")";
    // ctx.lineWidth = 2;
    // ctx.beginPath();
    // ctx.moveTo(points[0].x, points[0].y);
    // for(let j = 1; j < points.length; j++){
    //     ctx.lineTo(points[j].x, points[j].y);
    // }
    // ctx.stroke();

    let bounceVectors = [];
    bounceVectors.push(new Vector(points[1].x - points[0].x, points[1].y - points[0].y));
    for(let j = 1; j < points.length-1; j++){
        let vec1 = new Vector(points[j-1].x - points[j].x, points[j-1].y - points[j].y);
        let vec2 = new Vector(points[j+1].x - points[j].x, points[j+1].y - points[j].y);
        vec1.normalize();
        vec2.normalize();
        let bounceVec = new Vector(vec1.x + vec2.x, vec1.y + vec2.y);
        bounceVec.normalize();
        bounceVectors.push(bounceVec);
    }
    bounceVectors.push(new Vector(points[points.length-2].x - points[points.length-1].x, points[points.length-2].y - points[points.length-1].y));

    let thickness = 80;
    let leftAnchors = [];
    let rightAnchors = [];
    let bv = bounceVectors[0];
    bv.rotate(-Math.PI/2);
    bv.normalize();
    leftAnchors.push(new Vector(points[0].x + bv.x * thickness, points[0].y + bv.y * thickness));
    rightAnchors.push(new Vector(points[0].x - bv.x * thickness, points[0].y - bv.y * thickness));
    for(let j = 1; j < points.length-1; j++){
        let toprev = new Vector(points[j-1].x - points[j].x, points[j-1].y - points[j].y);
        toprev.normalize();
        if(j%2 == 0){
            bv = bounceVectors[j].clone();
            bv.normalize();
            let ddot = toprev.dot(bv);
            let angle = Math.acos(ddot);
            let fac = Math.sqrt(1 + Math.pow(Math.tan(angle), 2));
            bv.rotate(-Math.PI/2);
            leftAnchors.push(new Vector(points[j].x + bv.x * thickness*fac, points[j].y + bv.y * thickness*fac));
            rightAnchors.push(new Vector(points[j].x - bv.x * thickness*fac, points[j].y - bv.y * thickness*fac));
        }
        else{
            bv = bounceVectors[j].clone();
            bv.normalize();
            let ddot = toprev.dot(bv);
            let angle = Math.acos(ddot);
            let fac = Math.sqrt(1 + Math.pow(Math.tan(angle), 2));
            bv.rotate(+Math.PI/2);
            leftAnchors.push(new Vector(points[j].x + bv.x * thickness*fac, points[j].y + bv.y * thickness*fac));
            rightAnchors.push(new Vector(points[j].x - bv.x * thickness*fac, points[j].y - bv.y * thickness*fac));
        }
    }
    bv = bounceVectors[bounceVectors.length-1];
    if(bounceVectors.length%2 == 0)
        bv.rotate(+Math.PI/2);
    else
        bv.rotate(-Math.PI/2);
    bv.normalize();
    leftAnchors.push(new Vector(points[points.length-1].x + bv.x * thickness, points[points.length-1].y + bv.y * thickness));
    rightAnchors.push(new Vector(points[points.length-1].x - bv.x * thickness, points[points.length-1].y - bv.y * thickness));

    ctx.strokeStyle = "rgb(" + 255*noise(3.13, i) + "," + 255*noise(3.13, i+1.3) + "," +  255*noise(3.13, i+2.8) + ")";
    for(let j = 0; j < points.length-1; j++){
        // polygon
        ctx.fillStyle = "rgb(" + 255*noise(.413+i, j) + "," + 255*noise(.413+i, j+1.3) + "," +  255*noise(.413+i, j+2.8) + ")";
        
        let gradient = ctx.createLinearGradient(points[j].x*SCALE, points[j].y*SCALE, points[j+1].x*SCALE, points[j+1].y*SCALE);
        // 'CanvasRenderingContext2D': The provided double value is non-finite.

        let dist = Math.sqrt(Math.pow(points[j+1].x - points[j].x, 2) + Math.pow(points[j+1].y - points[j].y, 2))*SCALE;
        let detail = 333;
        let steps = 1 + Math.floor(dist/detail);
        for(let k = 0; k <= steps; k++){
            let ratio = k/steps;
            let ration = (k+1)/steps;
            //gradient.addColorStop(ratio, "rgb(" + 255*noise(.413+i, j, k) + "," + 255*noise(.413+i, j+1.3, k) + "," +  255*noise(.413+i, j+2.8, k) + ")");
            // hsv color
            let hue = (20*noise(.413+i*12.31, j*12.31, k*12.31))%1;
            let saturation = 1;
            let value = 1;
            let rgb = hsvToRgb(hue, saturation, value);
            if(k%3==0){
                rgb = [255,0,0];
            }
            if(k%3==1){
                rgb = [255,255,0];
            }
            if(k%3==2){
                rgb = [20,50,200];
            }
            let hue2 = (20*noise(.413+i*12.31, j*12.31, (k+1)*12.31))%1;
            let saturation2 = 1;
            let value2 = 1;
            let rgb2 = hsvToRgb(hue2, saturation2, value2);
            if((k+1)%3==0){
                rgb2 = [255,0,0];
            }
            if((k+1)%3==1){
                rgb2 = [255,255,0];
            }
            if((k+1)%3==2){
                rgb2 = [20,50,200];
            }
            gradient.addColorStop(ratio, "rgb(" + rgb[0] + "," + rgb[1] + "," +  rgb[2] + ")");
            let detail2 = detail/3;
            let jit = .0;
            if(k < steps){
                let c = oklab.sRGBToOklab(rgb[0]/255., rgb[1]/255., rgb[2]/255.);
                let c2 = oklab.sRGBToOklab(rgb2[0]/255., rgb2[1]/255., rgb2[2]/255.);
                for(let oo = 0; oo < detail2; oo++){
                    let qq = Math.pow(oo/detail2, 1);
                    let cc = [c.L+(c2.L-c.L)*qq, c.a+(c2.a-c.a)*qq, c.b+(c2.b-c.b)*qq];
                    let rgb3 = oklab.oklabTosRGB(cc[0], cc[1] + jit*(-.5+Math.random()), cc[2] + jit*(-.5+Math.random()));
                    let rgb4 = oklab.oklabTosRGB(cc[0], cc[1], cc[2]);
                    rgb3.r *= 255;
                    rgb3.g *= 255;
                    rgb3.b *= 255;
                    rgb4.r = rgb[0] + (rgb2[0]-rgb[0])*qq;
                    rgb4.g = rgb[1] + (rgb2[1]-rgb[1])*qq;
                    rgb4.b = rgb[2] + (rgb2[2]-rgb[2])*qq;
                    //gradient.addColorStop(ratio+1./steps*qq, "rgb(" + rgb3.r + "," + rgb3.g + "," +  rgb3.b + ")");
                    let qq2 = power(oo/detail2, .5);
                    // gradient.addColorStop(ratio+1./steps*qq2, "rgb(" + rgb3.r + "," + rgb3.g + "," +  rgb3.b + ")");
                    gradient.addColorStop(ratio+(ration-ratio)*qq2, "rgb(" + rgb3.r + "," + rgb3.g + "," +  rgb3.b + ")");
                }
            }
        }
        ctx.fillStyle = gradient;
        ctx.beginPath();
        ctx.moveTo(leftAnchors[j].x*SCALE, leftAnchors[j].y*SCALE);
        ctx.lineTo(leftAnchors[j+1].x*SCALE, leftAnchors[j+1].y*SCALE);
        ctx.lineTo(rightAnchors[j+1].x*SCALE, rightAnchors[j+1].y*SCALE);
        ctx.lineTo(rightAnchors[j].x*SCALE, rightAnchors[j].y*SCALE);
        ctx.closePath();
        ctx.fill();
        // ctx.stroke();
    }
}

// on load html, no jquery
window.onload = main;
window.addEventListener('resize', onresize, false);

let isDown = false;
let isMoving = false;

function resample(curve, step){
    let resampledCurve = [];
    let curveLength = 0;

    for(let i = 1; i < curve.length; i++){
        let dx = curve[i].x - curve[i-1].x;
        let dy = curve[i].y - curve[i-1].y;
        curveLength += Math.sqrt(dx*dx + dy*dy);
    }

    let stepLength = step;
    let currentLength = 0;
    let currentIndex = 0;
    let currentPoint = curve[0];
    resampledCurve.push(currentPoint);
    for(let i = 1; i < curve.length-1; i++){
        let dx = curve[i].x - curve[i-1].x;
        let dy = curve[i].y - curve[i-1].y;
        let dx2 = curve[i+1].x - curve[i].x;
        let dy2 = curve[i+1].y - curve[i].y;

        let dotproduct = dx*dx2 + dy*dy2;

        let segmentLength = Math.sqrt(dx*dx + dy*dy);
        currentLength += segmentLength;
        //if(currentLength >= stepLength){
        // if(currentLength >= stepLength){
        //     let ratio = (currentLength - stepLength) / segmentLength;
        //     let newX = curve[i-1].x + ratio * dx;
        //     let newY = curve[i-1].y + ratio * dy;
        //     resampledCurve.push([newX, newY]);
        //     currentLength = 0;
        // }
        if(dotproduct < 0){
            let newX = curve[i].x;
            let newY = curve[i].y;
            resampledCurve.push(new Vector(newX, newY));
            currentLength = 0;
        }
    }
    resampledCurve.push(curve[curve.length-1]);
    return resampledCurve;
}

function renderCursor(event){
    ctx.fillStyle = "#111111";
    ctx.beginPath();
    ctx.arc(event.clientX*SCALE, event.clientY*SCALE, 5, 0, 2 * Math.PI);
    ctx.fill();
}

function setCanvasEvents(){
    canvas.addEventListener('mousedown', function(event) {
        isDown = true;
        isMoving = false;
        currentCurve.push(new Vector(event.clientX, event.clientY));
    });
    
    canvas.addEventListener('mousemove', function(event) {
        let ddist = 100;
        if(currentCurve.length > 0){
            ddist = Math.sqrt(Math.pow(event.clientX - currentCurve[currentCurve.length-1].x, 2) + Math.pow(event.clientY - currentCurve[currentCurve.length-1].y, 2));
        }
        if (isDown && ddist > 10) {
            // if(currentCurve.length > 2){
            //     let angle1 = Math.atan2(event.clientY - currentCurve[currentCurve.length-1].y, event.clientX - currentCurve[currentCurve.length-1].x);
            //     let angle2 = Math.atan2(currentCurve[currentCurve.length-1].y - currentCurve[currentCurve.length-2].y, currentCurve[currentCurve.length-1].x - currentCurve[currentCurve.length-2].x);

            //         console.log(currentCurve.length, Math.abs(angle1 - angle2));
            //         if(Math.abs(angle1 - angle2) > 3.14){
            //         isMoving = true;
            //         currentCurve.push([event.clientX, event.clientY]);
            //         renderCursor(event);
            //     }
            //     else{
            //         renderCursor(event);
            //     }
            // }
            isMoving = true;
            currentCurve.push(new Vector(event.clientX, event.clientY));
            renderCursor(event);
        }
    });

    // mouse clicked hold
    
    canvas.addEventListener('mouseup', function(event) {
        let curveCopy = currentCurve.slice();

        curveCopy = resample(curveCopy, 522);
        curves.push(curveCopy);

        renderCurves();

        currentCurve = [];
        isDown = false;
        isMoving = false;
    });
}

// handle keys
document.addEventListener('keydown', function(event) {
    if(event.key == 'q') {
        // space
        curves = [];
        renderCurves();
    }
});