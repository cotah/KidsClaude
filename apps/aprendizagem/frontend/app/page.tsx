import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Mascot } from '@/components/ui/mascot-bubble';

/**
 * Landing page pública - conforme spec seção 8.1
 */
export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-sunny-100 via-white to-mint-100">
      {/* Header */}
      <header className="container mx-auto px-4 py-6">
        <nav className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Mascot size="sm" expression="happy" />
            <span className="text-2xl font-bold text-gray-800">Aprendizagem</span>
          </div>
          <div className="flex space-x-4">
            <Button variant="ghost" asChild>
              <Link href="/login">Entrar</Link>
            </Button>
            <Button variant="sunny" asChild>
              <Link href="/signup">Começar Grátis</Link>
            </Button>
          </div>
        </nav>
      </header>

      {/* Hero Section */}
      <main className="container mx-auto px-4 py-12">
        <section className="text-center space-y-8">
          <div className="space-y-4">
            <h1 className="text-4xl md:text-6xl font-bold text-gray-900">
              Ensine seus filhos a usar
              <span className="text-sunny-500 block">Inteligência Artificial</span>
            </h1>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Uma forma segura, divertida e educativa para crianças e adolescentes de
              6 a 18 anos aprenderem a conversar com assistentes de IA como a Claude.
            </p>
          </div>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button variant="sunny" size="kid-lg" asChild>
              <Link href="/signup">
                Começar Agora - Grátis
              </Link>
            </Button>
            {/* Removido link para /demo: rota fora do escopo do MVP */}
            <Button variant="outline" size="kid-lg" asChild>
              <a href="#como-funciona">Ver Como Funciona</a>
            </Button>
          </div>
        </section>

        {/* Features Section */}
        <section className="mt-24 grid md:grid-cols-3 gap-8">
          <FeatureCard
            icon="🛡️"
            title="100% Seguro"
            description="Moderação automática garante que seu filho tenha uma experiência segura e adequada para a idade."
          />
          <FeatureCard
            icon="🎮"
            title="Divertido"
            description="Lições interativas, desafios e recompensas mantêm a criança engajada no aprendizado."
          />
          <FeatureCard
            icon="📊"
            title="Controle Total"
            description="Acompanhe o progresso, veja transcrições das conversas e defina limites de tempo."
          />
        </section>

        {/* How it Works */}
        <section id="como-funciona" className="mt-24 text-center">
          <h2 className="text-3xl font-bold text-gray-900 mb-12">
            Como Funciona
          </h2>
          <div className="grid md:grid-cols-4 gap-8">
            <StepCard number={1} title="Cadastro do Responsável" description="Você se cadastra e cria perfis para seus filhos" />
            <StepCard number={2} title="Escolha do Avatar" description="Cada criança escolhe seu avatar favorito" />
            <StepCard number={3} title="Lições Interativas" description="A criança aprende através de lições curtas e divertidas" />
            <StepCard number={4} title="Conversa Guiada" description="Prompts seguros permitem conversa natural com a IA" />
          </div>
        </section>

        {/* CTA Section */}
        <section className="mt-24 text-center bg-white rounded-kid-lg p-12 shadow-xl">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">
            Pronto para começar?
          </h2>
          <p className="text-lg text-gray-600 mb-8">
            Crie sua conta gratuita e dê aos seus filhos uma vantagem no futuro digital.
          </p>
          <Button variant="sunny" size="kid-lg" asChild>
            <Link href="/signup">
              Começar Grátis Agora
            </Link>
          </Button>
        </section>
      </main>

      {/* Footer */}
      <footer className="mt-24 border-t border-gray-200 py-12">
        <div className="container mx-auto px-4 text-center text-gray-600">
          <p>&copy; 2024 Aprendizagem. Feito com ❤️ para o futuro das crianças.</p>
          {/* Privacidade/Termos/Contato sao paginas fora do MVP; espaco reservado para fase 2. */}
        </div>
      </footer>
    </div>
  );
}

function FeatureCard({ icon, title, description }: {
  icon: string;
  title: string;
  description: string;
}) {
  return (
    <Card className="text-center">
      <CardContent className="pt-6">
        <div className="text-4xl mb-4">{icon}</div>
        <h3 className="text-xl font-semibold mb-2">{title}</h3>
        <p className="text-gray-600">{description}</p>
      </CardContent>
    </Card>
  );
}

function StepCard({ number, title, description }: {
  number: number;
  title: string;
  description: string;
}) {
  return (
    <div className="space-y-4">
      <div className="w-12 h-12 bg-sunny-500 text-white rounded-full flex items-center justify-center font-bold text-lg mx-auto">
        {number}
      </div>
      <h3 className="font-semibold">{title}</h3>
      <p className="text-gray-600 text-sm">{description}</p>
    </div>
  );
}