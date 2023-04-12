interface KeyPair {
    Public: string;
    Secret: string;
}

interface Curve25519 {
    GenerateKeyPair(): KeyPair;
    GenerateSessionKey(Sender: string, Recipient: string): string;
}

interface AES {
    GenerateKey(): string;
    Encrypt(Data: string, Key: string): string;
    Decrypt(Data: string, Key: string): string;
}
export default interface crypto {
    EC25519: Curve25519;
    AES: AES;
}