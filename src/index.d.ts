/// <reference types="@rbxts/types"/>

interface KeyPair {
    Public: string,
    Secret: string
}

declare namespace Curve25519 {
    function GenerateKeyPair(): KeyPair;
    function GenerateSessionKey(Sender: string, Recipient: string): string;
}

declare namespace AES {
    function GenerateKey(): string;
    function Encrypt(Data: string, Key: string): string;
    function Decrypt(Data: string, Key: string): string;
}

declare namespace Base64 {
    function Encode(Data: string): string;
    function Decode(Data: string): string;
}

declare function Sha256(Data: string, Salt?: string): string;

export { Curve25519, AES, Base64, Sha256 };