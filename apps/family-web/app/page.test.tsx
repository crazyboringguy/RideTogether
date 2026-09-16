import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';

import HomePage from './page';

describe('Family trip viewer foundation', () => {
  it('identifies the read-only family viewer', () => {
    const page = renderToStaticMarkup(<HomePage />);

    expect(page).toContain('RideTogether Family Trip Viewer');
    expect(page).toContain('read-only family trip view');
  });
});
