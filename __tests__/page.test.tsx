import { render, screen } from '@testing-library/react'
import Home from '@/app/page'

describe('Home Page', () => {
  it('renders the welcome message', () => {
    render(<Home />)
    expect(screen.getByText("Welcome, glad you're here!")).toBeInTheDocument()
  })
})
