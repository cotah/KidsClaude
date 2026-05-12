// Pagina 404 minima sem dependencias - evita problemas de hidratacao no prerender.
export default function NotFound() {
  return (
    <div style={{ padding: 48, textAlign: 'center', fontFamily: 'sans-serif' }}>
      <h1 style={{ fontSize: 32, fontWeight: 'bold' }}>Pagina nao encontrada</h1>
      <p style={{ marginTop: 16 }}>
        Verifique o endereco ou volte para a pagina inicial.
      </p>
      <p style={{ marginTop: 24 }}>
        <a href="/" style={{ color: '#7c3aed' }}>Ir para o inicio</a>
      </p>
    </div>
  );
}
