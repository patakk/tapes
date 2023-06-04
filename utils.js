export class Quad{
    constructor(p1, p2, p3, p4){
        this.p1 = p1;
        this.p2 = p2;
        this.p3 = p3;
        this.p4 = p4;
    }

}

export class Vector{
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
