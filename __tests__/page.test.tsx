import { render, screen } from '@testing-library/react'
import Home from '@/app/page'

describe('Home Page', () => {
  it('renders the Next.js logo', () => {
    render(<Home />)
    const logo = screen.getByAltText('Next.js logo')
    expect(logo).toBeInTheDocument()
  })

  it('renders the main heading', () => {
    render(<Home />)
    const heading = screen.getByRole('heading', { level: 1 })
    expect(heading).toHaveTextContent('To get started, edit the page.tsx file.')
  })

  it('renders the Templates link with correct href', () => {
    render(<Home />)
    const templatesLink = screen.getByRole('link', { name: 'Templates' })
    expect(templatesLink).toHaveAttribute(
      'href',
      'https://vercel.com/templates?framework=next.js&utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app'
    )
  })

  it('renders the Learning link with correct href', () => {
    render(<Home />)
    const learningLink = screen.getByRole('link', { name: 'Learning' })
    expect(learningLink).toHaveAttribute(
      'href',
      'https://nextjs.org/learn?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app'
    )
  })

  it('renders the Deploy Now button with Vercel logo', () => {
    render(<Home />)
    const deployLink = screen.getByRole('link', { name: /Deploy Now/i })
    expect(deployLink).toHaveAttribute(
      'href',
      'https://vercel.com/new?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app'
    )
    expect(deployLink).toHaveAttribute('target', '_blank')
    expect(deployLink).toHaveAttribute('rel', 'noopener noreferrer')

    const vercelLogo = screen.getByAltText('Vercel logomark')
    expect(vercelLogo).toBeInTheDocument()
  })

  it('renders the Documentation link', () => {
    render(<Home />)
    const docsLink = screen.getByRole('link', { name: 'Documentation' })
    expect(docsLink).toHaveAttribute(
      'href',
      'https://nextjs.org/docs?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app'
    )
    expect(docsLink).toHaveAttribute('target', '_blank')
    expect(docsLink).toHaveAttribute('rel', 'noopener noreferrer')
  })

  it('renders the description paragraph', () => {
    render(<Home />)
    expect(
      screen.getByText(/Looking for a starting point or more instructions/i)
    ).toBeInTheDocument()
  })

  it('renders the welcome banner', () => {
    render(<Home />)
    expect(screen.getByText('Welcome to our site!')).toBeInTheDocument()
  })

  it('renders the glad to have you message', () => {
    render(<Home />)
    expect(screen.getByText('Glad to have you')).toBeInTheDocument()
  })
})
