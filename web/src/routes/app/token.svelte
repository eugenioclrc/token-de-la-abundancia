<script>
  import { onMount } from 'svelte'
  import { page } from '$app/stores';
  import { contracts, init, getTokensNetwork } from '../../store/index';
import Token from '$lib/Token.svelte';

  let token = {
    childs: []
  };

  function responseToToken(d) {
    if (String(d.id) === '0') {
      return null;
    }
    return { 
      id: String(d.id),
      status: d.status_,
      owner: d.owner,
      detail: d.detail,
    };
  }

  onMount(async () => {
    await init();
    const tokenid = $page.query.get('token');
    const net = await getTokensNetwork(tokenid);
    const parsedNet = net.map(responseToToken);
    token = parsedNet[1];
    token.parent = parsedNet[0];

    token.childs = [parsedNet[2], parsedNet[3]];

    if (parsedNet[2]) {
      parsedNet[2].childs = [
        // _referrer[_referrer[id][0]][0];
        parsedNet[4],
        // _referrer[_referrer[id][0]][1];
        parsedNet[5],
      ];
    }

    if(parsedNet[3]) {
      parsedNet[3].childs = [
        // _referrer[_referrer[id][1]][0];
        parsedNet[6],
        // _referrer[_referrer[id][1]][1];
        parsedNet[7]
      ];
    }

    if (parsedNet[4]) {
      parsedNet[4].childs = [
        // tokenNetwork_[8] = _referrer[_referrer[_referrer[id][0]][0]][0];
        parsedNet[8],
        // tokenNetwork_[9] = _referrer[_referrer[_referrer[id][0]][0]][1];
        parsedNet[9],
      ];
    }
    
    if (parsedNet[5]) {
      parsedNet[5].childs = [
        // tokenNetwork_[10] = _referrer[_referrer[_referrer[id][0]][1]][0];
        parsedNet[10],
        // tokenNetwork_[11] = _referrer[_referrer[_referrer[id][0]][1]][1];
        parsedNet[11],
      ];
    }

    if (parsedNet[6]) {
      parsedNet[6].childs = [
        // tokenNetwork_[12] = _referrer[_referrer[_referrer[id][1]][0]][0];
        parsedNet[12],
        // tokenNetwork_[13] = _referrer[_referrer[_referrer[id][1]][0]][1];
        parsedNet[13],
      ];
    }

    if (parsedNet[7]) {
      parsedNet[7].childs = [
        // tokenNetwork_[14] = _referrer[_referrer[_referrer[id][1]][1]][0];
        parsedNet[14],
        // tokenNetwork_[15] = _referrer[_referrer[_referrer[id][1]][1]][1];
        parsedNet[15],
      ];
    }
    console.log({token})
  });

</script>
<div class="m-4">
  {#if token.parent}
    <div class="level-1 rectangle" style="margin-bottom: 20px;">
      <Token token={token.parent}></Token>
    </div>
  {/if}
  <div class="level-1 rectangle">
    <Token {token}></Token>
  </div>
  <!-- <button on:click={() => { alert('todo'); }} class="font-bold rounded bg-gray-200 p-2">UNIRME!</button> -->
  <ol class="level-2-wrapper">
  {#each token.childs as level1}
    {#if level1}
      <li>
        <div class="level-2 rectangle">
          <Token token={level1}></Token>
        </div>
        <ol class="level-3-wrapper">
          {#each level1.childs || [] as level2}
            {#if level2}
              <li>
                <div class="level-3 rectangle">
                  <Token token={level2}></Token>
                </div>
                <ol class="level-4-wrapper">
                  {#each level2.childs || [] as level3}
                    {#if level3}
                      <li>
                        <div class="level-4 rectangle">
                          <Token token={level3}></Token>
                        </div>
                      </li>
                    {:else}
                      <li>
                        <h4 class="level-4 rectangle">Chispita! unete! nanana nanana mandala</h4>
                      </li>
                    {/if}
                  {/each}
                </ol>
              </li>
            {:else}
              <li>
                <h3 class="level-3 rectangle">Chispita! unete! nanana nanana mandala</h3>
              </li>
            {/if}
          {/each}
        </ol>
      </li>
    {:else}
      <li>
        <h2 class="level-2 rectangle">Chispita! unete! nanana nanana mandala</h2>
      </li>
    {/if}
  {/each}
  </ol>
  </div>
  <style>


:root {
  --level-1: #8dccad;
  --level-2: #f5cc7f;
  --level-3: #7b9fe0;
  --level-4: #f27c8d;
  --black: black;
}

ol {
  @apply list-none;
}

.rectangle {
  position: relative;
  padding: 20px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
}


/* LEVEL-1 STYLES
–––––––––––––––––––––––––––––––––––––––––––––––––– */
.level-1 {
  width: 50%;
  margin: 0 auto 40px;
  background: var(--level-1);
}

.level-1::before {
  content: "";
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  width: 2px;
  height: 20px;
  background: var(--black);
}


/* LEVEL-2 STYLES
–––––––––––––––––––––––––––––––––––––––––––––––––– */
.level-2-wrapper {
  position: relative;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
}

.level-2-wrapper::before {
  content: "";
  position: absolute;
  top: -20px;
  left: 25%;
  width: 50%;
  height: 2px;
  background: var(--black);
}

.level-2-wrapper::after {
  display: none;
  content: "";
  position: absolute;
  left: -20px;
  bottom: -20px;
  width: calc(100% + 20px);
  height: 2px;
  background: var(--black);
}

.level-2-wrapper li {
  position: relative;
}

.level-2-wrapper > li::before {
  content: "";
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  width: 2px;
  height: 20px;
  background: var(--black);
}

.level-2 {
  width: 70%;
  margin: 0 auto 40px;
  background: var(--level-2);
}

.level-2::before {
  content: "";
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  width: 2px;
  height: 20px;
  background: var(--black);
}

.level-2::after {
  display: none;
  content: "";
  position: absolute;
  top: 50%;
  left: 0%;
  transform: translate(-100%, -50%);
  width: 20px;
  height: 2px;
  background: var(--black);
}


/* LEVEL-3 STYLES
–––––––––––––––––––––––––––––––––––––––––––––––––– */
.level-3-wrapper {
  position: relative;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  grid-column-gap: 20px;
  width: 90%;
  margin: 0 auto;
}

.level-3-wrapper::before {
  content: "";
  position: absolute;
  top: -20px;
  left: calc(25% - 5px);
  width: calc(50% + 10px);
  height: 2px;
  background: var(--black);
}

.level-3-wrapper > li::before {
  content: "";
  position: absolute;
  top: 0;
  left: 50%;
  transform: translate(-50%, -100%);
  width: 2px;
  height: 20px;
  background: var(--black);
}

.level-3 {
  margin-bottom: 20px;
  background: var(--level-3);
}


/* LEVEL-4 STYLES
–––––––––––––––––––––––––––––––––––––––––––––––––– */
.level-4-wrapper {
  position: relative;
  width: 80%;
  margin-left: auto;
}

.level-4-wrapper::before {
  content: "";
  position: absolute;
  top: -20px;
  left: -20px;
  width: 2px;
  height: calc(100% + 20px);
  background: var(--black);
}

.level-4-wrapper li + li {
  margin-top: 20px;
}

.level-4 {
  font-weight: normal;
  background: var(--level-4);
}

.level-4::before {
  content: "";
  position: absolute;
  top: 50%;
  left: 0%;
  transform: translate(-100%, -50%);
  width: 20px;
  height: 2px;
  background: var(--black);
}


/* MQ STYLES
–––––––––––––––––––––––––––––––––––––––––––––––––– */
@media screen and (max-width: 700px) {
  .rectangle {
    padding: 20px 10px;
  }

  .level-1,
  .level-2 {
    width: 100%;
  }

  .level-1 {
    margin-bottom: 20px;
  }

  .level-1::before,
  .level-2-wrapper > li::before {
    display: none;
  }
  
  .level-2-wrapper,
  .level-2-wrapper::after,
  .level-2::after {
    display: block;
  }

  .level-2-wrapper {
    width: 90%;
    margin-left: 10%;
  }

  .level-2-wrapper::before {
    left: -20px;
    width: 2px;
    height: calc(100% + 40px);
  }

  .level-2-wrapper > li:not(:first-child) {
    margin-top: 50px;
  }
}

</style>