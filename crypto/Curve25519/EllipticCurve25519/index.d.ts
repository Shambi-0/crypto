export default interface EllipticCurve25519 {
    ScalarMultiplication(Output: number[], N: number[], P: number[]): void;
    ScalarMultiplicationBase(Output: number[], Input: number[]): void;
}