import { createGlobalStyle } from 'styled-components';
import Pricedown from 'fonts/pricedown.ttf';

const GlobalStyle = createGlobalStyle`
  @font-face {
    font-family: 'Pricedown';
    src: url(${Pricedown});
  }
`;

export default GlobalStyle;
