import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MascotBubble, Mascot } from './mascot-bubble';

// Testes do componente MascotBubble - mantemos focados no contrato real do componente.
describe('MascotBubble', () => {
  it('renderiza children dentro do balao', () => {
    render(<MascotBubble>Ola, crianca!</MascotBubble>);
    expect(screen.getByText('Ola, crianca!')).toBeInTheDocument();
  });

  it('aplica a classe da variante cheerful', () => {
    const { container } = render(
      <MascotBubble variant="cheerful">Texto</MascotBubble>
    );
    // O wrapper interno aplica a classe da variante (border-sunset-200).
    const bubble = container.querySelector('.border-sunset-200');
    expect(bubble).not.toBeNull();
  });

  it('aplica a classe da variante warning', () => {
    const { container } = render(
      <MascotBubble variant="warning">Atencao</MascotBubble>
    );
    const bubble = container.querySelector('.border-sunset-300');
    expect(bubble).not.toBeNull();
  });

  it('aplica className customizada no wrapper externo', () => {
    const { container } = render(
      <MascotBubble className="custom-class">Texto</MascotBubble>
    );
    expect(container.firstChild).toHaveClass('custom-class');
  });

  it('omite a calda quando showTail=false', () => {
    const { container } = render(
      <MascotBubble showTail={false}>Sem calda</MascotBubble>
    );
    // A calda usa "rotate-45"; nao deve aparecer com showTail=false.
    const tail = container.querySelector('.rotate-45');
    expect(tail).toBeNull();
  });
});

describe('Mascot', () => {
  it('renderiza o emoji do mascote', () => {
    render(<Mascot />);
    expect(screen.getByText('🤖')).toBeInTheDocument();
  });

  it('aplica classe de tamanho lg', () => {
    const { container } = render(<Mascot size="lg" />);
    expect(container.firstChild).toHaveClass('w-32');
  });
});
