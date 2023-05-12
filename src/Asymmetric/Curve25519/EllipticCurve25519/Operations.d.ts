export default interface Operations {
    NOT(X: number): number;
    AND(X: number, Y: number): number;
    OR(X: number, Y: number): number;
    XOR(X: number, Y: number): number;
    
    LSHIFT(X: number, Y: number): number;
    RSHIFT(X: number, Y: number): number;
}