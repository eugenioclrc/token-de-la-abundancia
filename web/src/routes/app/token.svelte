<script context="module">
	export const router = false;
</script>
<script>
  import { onMount } from 'svelte'
  import { page } from '$app/stores';
  import { contracts, init, getTokensNetwork } from '../../store/index';
  import { parseEther } from "@ethersproject/units";
  import Token from '$lib/Token.svelte';

  let token = null;
  let loading = true;
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

  let currentPage = '';

  $: if (currentPage && $page.query.get('token') !== currentPage) {
    document.location.reload();
  }

  function getQueryVar(varName){
    // Grab and unescape the query string - appending an '&' keeps the RegExp simple
    // for the sake of this example.
    const queryStr = unescape(window.location.search) + '&';

    // Dynamic replacement RegExp
    const regex = new RegExp('.*?[&\\?]' + varName + '=(.*?)&.*');

    // Apply RegExp to the query string
    const val = queryStr.replace(regex, "$1");

    // If the string is the same, we didn't find a match - return false
    return val == queryStr ? false : val;
}

  onMount(async () => {
    await init();
    let tokenid, networkId;

    try {
      [tokenid, networkId] = $page.query.get('token').split('-');
    } catch (e) {
      [tokenid, networkId] = getQueryVar('token').split('-');
    }
    currentPage = $page.query.get('token');
    const net = await getTokensNetwork(tokenid);
    const parsedNet = net.map(responseToToken);
    token = parsedNet[1];

    if (token) {
      token.parent = parsedNet[0];
      token.childs = [parsedNet[2], parsedNet[3]];
    }

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
    loading = false;
  });

  async function join(tokenId) {
    loading = true;
    try {
      const dream = prompt('Cual es tu sueño?');
      const tx = await contracts.telarNFT.mint(tokenId, dream, {value: parseEther("0.025") });
      await tx.wait();
      document.location.reload();
    } catch(err ) {
    }
    
    loading = false;
    // re cabeza
  }


</script>
{#if loading}
  loading
{:else if !token}
  <div class="shadow m-6 p-3">
      <div class="text-red-600">
        <h4 class="text-xl">Error</h4>
        <p class="text-lg">Token not found</p>
        <a class="text-blue-800" href="/app">List all tokens</a>
      </div>  
  </div>
{:else}
  <div class="m-4">
    {#if token.parent}
      <div class="level-1 rectangle border " 
      class:border-red-700={token.parent.status == 0}
      class:border-blue-600={token.parent.status == 1}
      class:border-green-100={token.parent.status == 2}
      class:border-blue-100={token.parent.status == 3}
      style="margin-bottom: 20px;">
        <Token token={token.parent}></Token>
      </div>
    {/if}
    <div class="level-1 rectangle border"
    class:border-red-700={token.status == 0}
      class:border-blue-600={token.status == 1}
      class:border-green-100={token.status == 2}
      class:border-blue-100={token.status == 3}>
      <Token {token}></Token>
    </div>
    <!-- <button on:click={() => { alert('todo'); }} class="font-bold rounded bg-gray-200 p-2">UNIRME!</button> -->
    <ol class="level-2-wrapper">
    {#each token.childs as level1}
      {#if level1}
        <li>
          <div class="level-2 rectangle border"
          class:border-red-700={level1.status == 0}
      class:border-blue-600={level1.status == 1}
      class:border-green-100={level1.status == 2}
      class:border-blue-100={level1.status == 3}>
            <Token token={level1}></Token>
          </div>
          <ol class="level-3-wrapper">
            {#each level1.childs || [] as level2}
              {#if level2}
                <li>
                  <div class="level-3 rectangle border"
                  class:border-red-700={level2.status == 0}
      class:border-blue-600={level2.status == 1}
      class:border-green-100={level2.status == 2}
      class:border-blue-100={level2.status == 3}>
                    <Token token={level2}></Token>
                  </div>
                  <ol class="level-4-wrapper">
                    {#each level2.childs || [] as level3}
                      {#if level3}
                        <li>
                          <div class="level-4 rectangle border"
                          class:border-red-700={level3.status == 0}
      class:border-blue-600={level3.status == 1}
      class:border-green-100={level3.status == 2}
      class:border-blue-100={level3.status == 3}>
                            <Token token={level3}></Token>
                          </div>
                        </li>
                      {:else}
                        <li>
                          <button class="level-4 rectangle bg-gray-200 p-2 hover:font-bold hover:bg-gray-300"
                          on:click={() => join(level2.id)}>Chispita! unete, click aqui! nanana nanana mandala</button>
                        </li>
                      {/if}
                    {/each}
                  </ol>
                </li>
              {:else}
                <li>
                  <button class="level-3 rectangle bg-gray-200 p-2 hover:font-bold hover:bg-gray-300"
                  on:click={() => join(level1.id)}>Chispita! unete, click aqui! nanana nanana mandala</button>
                </li>
              {/if}
            {/each}
          </ol>
        </li>
      {:else}
        <li>
          <button class="level-2 rectangle bg-gray-200 p-2 hover:font-bold hover:bg-gray-300"
          on:click={() => join(token.id)}>Chispita! unete, click aqui! nanana nanana mandala</button>
        </li>
      {/if}
    {/each}
    </ol>
    </div>
{/if}
  <style>


:root {

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