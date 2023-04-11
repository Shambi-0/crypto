interface KeyPair {
    Public: string;
    Secret: string;
}

export default interface Curve25519 {
    GenerateKeyPair(): KeyPair;
    GenerateSessionKey(Sender: string, Recipient: string): string;
}